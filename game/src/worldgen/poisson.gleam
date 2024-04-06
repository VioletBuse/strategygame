import worldgen/empty_grid
import worldgen/grid_utils
import gleam/result

type Grid =
  List(List(#(Float, Float)))

pub fn poisson(width: Int, height: Int) -> Result(List(#(Float, Float)), Nil) {
  empty_grid.generate_empty_grid(width, height)
  |> grid_utils.iterate(loop_generation(50))
  |> result.map(grid_utils.export_grid)
}

fn try_generate_point(grid: Grid, x: Int, y: Int) -> Result(Grid, Nil) {
  Ok(grid)
}

fn loop_generation(iters: Int) -> fn(Grid, Int, Int) -> Grid {
  fn(grid: Grid, x: Int, y: Int) { loop_generation_internal(grid, x, y, iters) }
}

fn loop_generation_internal(grid: Grid, x: Int, y: Int, iters: Int) -> Grid {
  case iters {
    0 -> grid
    _ ->
      case try_generate_point(grid, x, y) {
        Ok(new_grid) -> new_grid
        Error(_) -> loop_generation_internal(grid, x, y, iters - 1)
      }
  }
}
