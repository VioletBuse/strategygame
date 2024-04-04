import gleam/list
import gleam/int
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

fn process_window_grid(
  in: List(List(Result(#(Float, Float), Nil))),
  original_size: Result(#(Int, Int), Nil),
) -> Result(Grid, Nil) {
  let processed = process_grid_loop_one(in)

  case size(processed), original_size {
    _, Error(_) -> Error(Nil)
    new_size, old_size if new_size != old_size -> Error(Nil)
    _, _ -> Ok(processed)
  }
}

fn process_grid_loop_one(in: List(List(Result(#(Float, Float), Nil)))) -> Grid {
  case in {
    [] -> []
    [single] -> [result.values(single)]
    [first, ..rest] -> [result.values(first), ..process_grid_loop_one(rest)]
  }
}

fn window_internal_translate(
  grid: Grid,
  size: Result(#(Int, Int), Nil),
  location: Result(#(Int, Int), Nil),
  x: Int,
  y: Int,
) -> Result(Entry, Nil) {
  case location, size {
    Error(_), _ | _, Error(_) -> Error(Nil)
    Ok(#(loc_x, loc_y)), Ok(#(width, height)) ->
      case
        at_point(
          grid,
          clamped_point(Ok(#(width, height)), loc_x + x, loc_y + y),
        )
      {
        Ok(entry) ->
          Ok(translate_entry(entry, int.to_float(x), int.to_float(y)))
        Error(_) -> Error(Nil)
      }
  }
}

pub fn window(grid: Grid, x: Int, y: Int) -> Result(Grid, Nil) {
  let size = size(grid)
  let location = Ok(#(x, y))

  process_window_grid(
    [
      [
        window_internal_translate(grid, size, location, -1, 1),
        window_internal_translate(grid, size, location, 0, 1),
        window_internal_translate(grid, size, location, 1, 1),
      ],
      [
        window_internal_translate(grid, size, location, -1, 0),
        window_internal_translate(grid, size, location, 0, 0),
        window_internal_translate(grid, size, location, 1, 0),
      ],
      [
        window_internal_translate(grid, size, location, -1, -1),
        window_internal_translate(grid, size, location, 0, -1),
        window_internal_translate(grid, size, location, 1, -1),
      ],
    ],
    Ok(#(3, 3)),
  )
}

fn translate_entry(entry: Entry, x: Float, y: Float) -> Entry {
  let #(prev_x, prev_y) = entry
  #(prev_x +. x, prev_y +. y)
}
