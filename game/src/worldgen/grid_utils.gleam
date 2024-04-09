import gleam/list
import gleam/int
import gleam/float
import gleam/result
import gleam/io

type Entry =
  #(Float, Float)

type Grid =
  List(List(Entry))

pub fn size(grid: Grid) -> Result(#(Int, Int), Nil) {
  case grid {
    [] -> Ok(#(0, 0))
    [single] -> Ok(#(1, list.length(single)))
    [first, ..rest] ->
      case size_loop(rest, list.length(first)) {
        Error(_) -> Error(Nil)
        Ok(height) -> Ok(#(list.length(grid), height))
      }
  }
}

pub fn size_loop(grid: Grid, acc: Int) -> Result(Int, Nil) {
  case grid {
    [] -> panic as "grid size loop should never get here"
    [last_row] ->
      case list.length(last_row) {
        last_row_length if last_row_length != acc -> Error(Nil)
        _ -> Ok(acc)
      }
    [first, ..rest] ->
      case list.length(first) {
        first_row_length if first_row_length != acc -> Error(Nil)
        first_row_length -> size_loop(rest, first_row_length)
      }
  }
}

pub fn clamped_point(
  size: Result(#(Int, Int), Nil),
  x: Int,
  y: Int,
) -> Result(#(Int, Int), Nil) {
  case size {
    Error(_) -> Error(Nil)
    Ok(#(0, 0)) -> Ok(#(0, 0))
    Ok(#(width, height)) ->
      case int.modulo(x, width) {
        Ok(new_x) ->
          case int.modulo(y, height) {
            Ok(new_y) -> Ok(#(new_x, new_y))
            Error(_) -> Error(Nil)
          }
        Error(_) -> Error(Nil)
      }
  }
}

pub fn at_point(
  grid: Grid,
  location: Result(#(Int, Int), Nil),
) -> Result(Entry, Nil) {
  case location {
    Error(_) -> Error(Nil)
    Ok(#(x, y)) ->
      case list.at(grid, x) {
        Ok(row) ->
          case list.at(row, y) {
            Ok(entry) -> Ok(entry)
            Error(_) -> Error(Nil)
          }
        Error(_) -> Error(Nil)
      }
  }
}

pub fn write_point(
  grid: Grid,
  x: Int,
  y: Int,
  value: #(Float, Float),
) -> Result(Grid, Nil) {
  size(grid)
  |> result.map(fn(size) {
    case size {
      #(width, height) if width <= x || height <= y -> Error(Nil)
      _ -> Ok(size)
    }
  })
  |> result.flatten
  |> result.map(fn(_size) {
    case list.split(grid, x) {
      #(before, [row, ..after]) -> Ok(#(before, row, after))
      _ -> Error(Nil)
    }
  })
  |> result.flatten
  |> result.map(fn(tuple) {
    let #(rows_before, row, rows_after) = tuple

    case list.split(row, y) {
      #(cells_before, [_cell, ..cells_after]) ->
        Ok(#(rows_before, cells_before, cells_after, rows_after))
      _ -> Error(Nil)
    }
  })
  |> result.flatten
  |> result.map(fn(tuple) {
    let #(rows_before, cells_before, cells_after, rows_after) = tuple

    list.concat([
      rows_before,
      [list.concat([cells_before, [value], cells_after])],
      rows_after,
    ])
  })
}

pub fn iterate(
  grid: Grid,
  function: fn(Grid, Int, Int) -> Grid,
) -> Result(Grid, Nil) {
  let adj_fn = fn(grid: Grid, x: Int, y: Int) { Ok(function(grid, x, y)) }

  case size(grid) {
    Ok(#(width, height)) -> iterate_loop(Ok(grid), width, height, 0, 0, adj_fn)
    Error(_) -> Error(Nil)
  }
}

pub fn iterate_result(
  grid: Grid,
  function: fn(Grid, Int, Int) -> Result(Grid, Nil),
) -> Result(Grid, Nil) {
  case size(grid) {
    Ok(#(width, height)) ->
      iterate_loop(Ok(grid), width, height, 0, 0, function)
    Error(_) -> Error(Nil)
  }
}

fn iterate_loop(
  grid: Result(Grid, Nil),
  width: Int,
  height: Int,
  x: Int,
  y: Int,
  function: fn(Grid, Int, Int) -> Result(Grid, Nil),
) -> Result(Grid, Nil) {
  case grid {
    Ok(grid) ->
      case x, y {
        _, _ if y >= height -> Ok(grid)
        _, _ if x >= width ->
          iterate_loop(Ok(grid), width, height, 0, y + 1, function)
        _, _ ->
          case function(grid, x, y) {
            Ok(new_grid) ->
              iterate_loop(Ok(new_grid), width, height, x + 1, y, function)
            Error(_) -> Error(Nil)
          }
      }
    Error(_) -> Error(Nil)
  }
}

pub fn point_distance(
  from: #(Float, Float),
  to: #(Float, Float),
) -> Result(Float, Nil) {
  case float.power(from.1 -. to.1, 2.0), float.power(from.0 -. to.0, 2.0) {
    Ok(y), Ok(x) ->
      case float.square_root(y +. x) {
        Ok(dist) -> Ok(dist)
        _ -> Error(Nil)
      }
    _, _ -> Error(Nil)
  }
}

pub fn distance(
  grid: Grid,
  from: #(Int, Int),
  to: #(Int, Int),
) -> Result(Float, Nil) {
  let #(x_from, y_from) = from
  let #(x_to, y_to) = to

  let point_from = at_point(grid, Ok(from))
  let point_to = at_point(grid, Ok(to))

  case point_from, point_to {
    Ok(#(x1, y1)), Ok(#(x2, y2))
      if x1 <. 0.0 || x2 <. 0.0 || y1 <. 0.0 || y2 <. 0.0
    -> Error(Nil)

    _, _ -> {
      let transformed = case point_from, point_to {
        Ok(#(x1, y1)), Ok(#(x2, y2)) ->
          Ok(
            #(#(x1 +. int.to_float(x_from), y1 +. int.to_float(y_from)), #(
              x2 +. int.to_float(x_to),
              y2 +. int.to_float(y_to),
            )),
          )
        _, _ -> Error(Nil)
      }

      transformed
      |> result.map(fn(v) { point_distance(v.0, v.1) })
      |> result.flatten
    }
  }
}

pub fn window(grid: Grid, x: Int, y: Int) -> Result(Grid, Nil) {
  size(grid)
  |> result.map(fn(dimensions) {
    case dimensions {
      #(width, height) if width < 3 || height < 3 || x > width || y > height ->
        Error(Nil)
      _ -> Ok(dimensions)
    }
  })
  |> result.flatten
  |> result.map(fn(dimensions) {
    let #(width, _) = dimensions

    case list.at(grid, 0), list.at(grid, width - 1) {
      Ok(row_one), Ok(last_row) ->
        Ok(list.concat([[last_row], grid, [row_one]]))
      _, _ -> Error(Nil)
    }
  })
  |> result.flatten
  |> result.map(list.map(_, fn(row) {
    case list.at(row, 0), list.at(row, list.length(row) - 1) {
      Ok(cell_one), Ok(last_cell) -> list.concat([[last_cell], row, [cell_one]])
      _, _ -> panic as "cells in this list don't exist for some reason"
    }
  }))
  |> result.map(fn(list) {
    case list.at(list.window(list, 3), x) {
      Ok(rows_window) -> Ok(rows_window)
      Error(_) -> Error(Nil)
    }
  })
  |> result.flatten
  |> result.map(list.map(_, fn(row) {
    case list.at(list.window(row, 3), y) {
      Ok(row_window) -> row_window
      Error(_) -> panic as "window should exist"
    }
  }))
}

/// return slice of a list from a: Inclusive, to b: Exclusive
pub fn list_range(list: List(a), from: Int, to: Int) -> List(a) {
  let #(f, _) = list.split(list, to)
  let #(_, res) = list.split(f, from)

  res
}

pub fn sized_window(
  grid: Grid,
  window_size: Int,
  x: Int,
  y: Int,
) -> Result(Grid, Nil) {
  case int.modulo(window_size, 2), size(grid) {
    Ok(1), Ok(#(width, height)) if x < width && y < height -> Ok(window_size)
    _, _ -> Error(Nil)
  }
  |> result.map(fn(_) { grid })
  |> result.map(fn(grid) {
    let length = float.truncate({ int.to_float(window_size) /. 2.0 })
    io.debug(length)
    #(length, grid)
  })
  |> result.map(fn(args) {
    case args {
      #(length, grid) -> {
        // size = 10, length = 2; 10 / 2 = 5 2 / 10 = 0.2 -> 1
        // size = 6, length = 10; 10 / 6 = 1.666 -> 2
        // size = 6, length = 25; 25 / 6 = 4.16 -> 5

        let expansion_grid_size = case size(grid), length {
          Ok(#(width, height)), length ->
            float.truncate(
              int.to_float(length)
              /. int.to_float(int.min(width, height))
              +. 1.0,
            )
          _, _ ->
            panic as "size should have run already, why is it failing now?"
        }

        let expansion_grid: Grid =
          list.range(0, expansion_grid_size)
          |> list.map(fn(_) { grid })
          |> list.concat
          |> list.map(fn(row) {
            list.range(0, expansion_grid_size)
            |> list.map(fn(_) { row })
            |> list.concat
          })

        let grid_with_expansion_for_window =
          list.concat([
            list_range(
              expansion_grid,
              list.length(expansion_grid) - length,
              list.length(expansion_grid),
            ),
            expansion_grid,
            list_range(expansion_grid, 0, length),
          ])
          |> list.map(fn(row) {
            list.concat([
              list_range(row, list.length(row) - length, list.length(row)),
              row,
              list_range(row, 0, length),
            ])
          })

        #(length, grid_with_expansion_for_window)
      }
    }
  })
  |> result.map(fn(args) {
    case args {
      #(length, expanded_grid) ->
        case list.at(list.window(expanded_grid, window_size), x) {
          Ok(val) -> Ok(#(length, val))
          _ -> Error(Nil)
        }
    }
  })
  |> result.flatten
  |> result.map(fn(args) {
    case args {
      #(_length, x_window) ->
        list.map(x_window, fn(col) { list.at(list.window(col, window_size), y) })
        |> result.values
    }
  })
}

pub fn export_grid(grid: Grid) -> List(#(Float, Float)) {
  let #(_, adjusted_grid) =
    list.map_fold(grid, 0, fn(x, row) {
      let #(_, adjusted_row) =
        list.map_fold(row, 0, fn(y, cell) {
          let #(cell_x, cell_y) = cell
          #(y + 1, #(cell_x, cell_y, x, y))
        })

      #(x + 1, adjusted_row)
    })

  export_grid_loop(adjusted_grid, [])
  |> list.map(fn(val) {
    let #(x, y, grid_x, grid_y) = val
    let #(grid_x_f, grid_y_f) = #(int.to_float(grid_x), int.to_float(grid_y))
    #(x +. grid_x_f, y +. grid_y_f)
  })
}

fn export_grid_loop(
  grid: List(List(#(Float, Float, Int, Int))),
  acc: List(#(Float, Float, Int, Int)),
) {
  let filterfn = fn(val: #(Float, Float, Int, Int)) -> Bool {
    case val {
      #(x, y, _, _) if x <. 0.0 || y <. 0.0 -> False
      _ -> True
    }
  }

  case grid {
    [] -> acc
    [last_list] -> list.concat([list.filter(last_list, filterfn), acc])
    [first_list, ..rest] ->
      list.concat([
        list.filter(first_list, filterfn),
        export_grid_loop(rest, acc),
      ])
  }
}

pub fn normalize_exported_grid(
  exported: List(#(Float, Float)),
) -> List(#(Float, Float)) {
  exported
  |> list.map(fn(v) { #(0, v.0, v.1) })
  |> normalize_exported_grid_with_ids
  |> list.map(fn(v) { #(v.1, v.2) })
}

pub fn normalize_exported_grid_with_ids(
  exported: List(#(a, Float, Float)),
) -> List(#(a, Float, Float)) {
  scale_exported_grid_to_size_with_ids(exported, 1)
}

pub fn scale_exported_grid_to_size(
  exported: List(#(Float, Float)),
  size: Int,
) -> List(#(Float, Float)) {
  exported
  |> list.map(fn(v) { #(0, v.0, v.1) })
  |> scale_exported_grid_to_size_with_ids(size)
  |> list.map(fn(v) { #(v.1, v.2) })
}

pub fn scale_exported_grid_to_size_with_ids(
  exported: List(#(a, Float, Float)),
  size: Int,
) -> List(#(a, Float, Float)) {
  case exported {
    [] -> []
    _ -> {
      let sorted_x =
        exported
        |> list.map(fn(v) { v.1 })
        |> list.sort(float.compare)
      let sorted_y =
        exported
        |> list.map(fn(v) { v.2 })
        |> list.sort(float.compare)

      let max_x = list.at(sorted_x, list.length(sorted_x) - 1)

      let max_y = list.at(sorted_y, list.length(sorted_y) - 1)

      case max_x, max_y {
        Ok(max_x), Ok(max_y) -> {
          let factor =
            int.to_float(size)
            /. int.to_float(float.truncate(float.max(max_x, max_y)) + 1)

          let mapped =
            list.map(exported, fn(point) {
              #(point.0, point.1 *. factor, point.2 *. factor)
            })

          mapped
        }
        _, _ -> []
      }
    }
  }
}
