import worldgen/empty_grid
import worldgen/grid_utils
import gleam/list
import gleam/result
import gleam/float

type Grid =
  List(List(#(Float, Float)))

pub fn poisson(width: Int, height: Int) -> Result(List(#(Float, Float)), Nil) {
  empty_grid.generate_empty_grid(width, height)
  |> grid_utils.iterate(loop_generation(25))
  |> result.map(grid_utils.export_grid)
}

fn try_generate_point(grid: Grid, x: Int, y: Int) -> Result(Grid, Nil) {
  let random_point = #(float.random(), float.random())

  let new_grid = grid_utils.write_point(grid, x, y, random_point)

  let window =
    new_grid
    |> result.map(grid_utils.window(_, x, y))
    |> result.flatten

  // [tol, top, tor] -> [0,2/ 1,2/ 2,2]
  // [lll, ori, rrr] -> [0,1/ 1,1/ 2,1]
  // [bol, bot, bor] -> [0,0/ 1,0/ 2,0]

  let valid_point =
    window
    |> result.map(fn(grid_window) {
      let comparisons = [
        #(0, 2),
        #(1, 2),
        #(2, 2),
        #(0, 1),
        #(2, 1),
        #(0, 0),
        #(1, 0),
        #(2, 0),
      ]

      let distance_results =
        list.map(comparisons, grid_utils.distance(grid_window, _, #(1, 1)))
      let valid_distances = result.values(distance_results)
      let too_small_distances =
        list.map(valid_distances, fn(dist) { dist <. 1.0 })

      case list.length(too_small_distances) {
        0 -> True
        _ -> False
      }
    })

  case valid_point {
    Ok(True) -> new_grid
    _ -> Error(Nil)
  }
}

fn loop_generation(iters: Int) -> fn(Grid, Int, Int) -> Grid {
  fn(grid: Grid, x: Int, y: Int) { loop_generation_internal(grid, x, y, iters) }
}

fn loop_generation_internal(grid: Grid, x: Int, y: Int, iters: Int) -> Grid {
  case iters {
    0 -> grid
    _ -> {
      case try_generate_point(grid, x, y) {
        Ok(new_grid) -> new_grid
        Error(_) -> loop_generation_internal(grid, x, y, iters - 1)
      }
    }
  }
}
