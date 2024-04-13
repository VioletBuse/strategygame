import gleam/float

pub type InternalGenerationPoint {
  Point(x: Float, y: Float)
  NoPointGenerated
}

// fn loop_over_grid(
//   grid: List(List(InternalGenerationPoint)),
//   square_count: Int,
//   x_index: Int,
//   y_index: Int,
//   min_distance: Float,
//   retries: Int,
// ) -> List(List(InternalGenerationPoint)) {
// }

pub fn internal_generate_empty_grid(
  size: Float,
  min_distance: Float,
) -> List(List(InternalGenerationPoint)) {
  let square_count = float.round(size /. min_distance)
  //   let square_size = size /. int.to_float(square_count)

  internal_generate_empty_grid_horizontal_loop(square_count, square_count, [])
}

fn internal_generate_empty_grid_horizontal_loop(
  num: Int,
  height: Int,
  acc: List(List(InternalGenerationPoint)),
) -> List(List(InternalGenerationPoint)) {
  case num {
    0 -> acc
    _ ->
      internal_generate_empty_grid_horizontal_loop(num - 1, height, [
        internal_generate_empty_grid_vertical_loop(height, []),
        ..acc
      ])
  }
}

fn internal_generate_empty_grid_vertical_loop(
  num: Int,
  acc: List(InternalGenerationPoint),
) -> List(InternalGenerationPoint) {
  case num {
    0 -> acc
    _ ->
      internal_generate_empty_grid_vertical_loop(num - 1, [
        NoPointGenerated,
        ..acc
      ])
  }
}
