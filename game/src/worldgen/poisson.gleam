import worldgen/empty_grid
import worldgen/grid_utils

type Grid =
  List(List(#(Float, Float)))

pub fn poisson(width: Int, height: Int) -> Grid {
  empty_grid.generate_empty_grid(width, height)
}
