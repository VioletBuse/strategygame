import gleam/list
import gleam/int
import gleam/float
import gleam/result

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

pub fn distance(
  grid: Grid,
  from: #(Int, Int),
  to: #(Int, Int),
) -> Result(Float, Nil) {
  let #(x_from, y_from) = from
  let #(x_to, y_to) = to

  let point_from = at_point(grid, Ok(from))
  let point_to = at_point(grid, Ok(to))

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
  |> result.map(fn(points) {
    let #(#(x1, y1), #(x2, y2)) = points

    case float.power(x2 -. x1, 2.0), float.power(y2 -. y1, 2.0) {
      Ok(term1), Ok(term2) -> Ok(term1 +. term2)
      _, _ -> Error(Nil)
    }
  })
  |> result.flatten
  |> result.map(fn(distance2) {
    case float.square_root(distance2) {
      Ok(dist) -> Ok(dist)
      _ -> Error(Nil)
    }
  })
  |> result.flatten
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
