type Grid =
  List(List(#(Float, Float)))

pub fn generate_empty_grid(width width: Int, height height: Int) -> Grid {
  case width, height {
    _, _ if width <= 0 -> []
    _, _ if height <= 0 -> []
    _, _ -> generate_empty_grid_loop(width, height, [])
  }
}

fn generate_empty_grid_loop(
  width width: Int,
  height height: Int,
  acc acc: Grid,
) -> Grid {
  case width {
    0 -> acc
    _ ->
      generate_empty_grid_loop(width - 1, height, [
        generate_list_of_points_loop(height, []),
        ..acc
      ])
  }
}

fn generate_list_of_points_loop(
  length length: Int,
  acc acc: List(#(Float, Float)),
) -> List(#(Float, Float)) {
  case length {
    0 -> acc
    _ -> generate_list_of_points_loop(length - 1, [#(-1.0, -1.0), ..acc])
  }
}
