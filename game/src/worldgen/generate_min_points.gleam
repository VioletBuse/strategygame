import gleam/result
import gleam/list
import gleam/int
import gleam/float
import worldgen/grid_utils
import worldgen/poisson.{poisson}

pub fn generate_minimum_outposts_normalized(
  player_count: Int,
) -> Result(List(#(Float, Float)), Nil) {
  generate_outer_loop(player_count, 0, 20)
  |> result.map(grid_utils.normalize_exported_grid)
}

fn generate_outer_loop(
  player_count: Int,
  current_iter: Int,
  max_iters: Int,
) -> Result(List(#(Float, Float)), Nil) {
  let size =
    player_count * 4
    |> int.square_root
    |> result.map(float.truncate)
    |> result.map(int.add(_, 1))
    |> result.map(int.add(_, current_iter))

  case size {
    Ok(size) ->
      case generate_loop(player_count, size, 5) {
        Ok(points) -> Ok(points)
        _ if current_iter > max_iters -> Error(Nil)
        _ -> generate_outer_loop(player_count, current_iter + 1, max_iters)
      }
    _ -> Error(Nil)
  }
}

fn generate_loop(
  required_amount: Int,
  size: Int,
  iters: Int,
) -> Result(List(#(Float, Float)), Nil) {
  let result = {
    poisson(size, size)
    |> result.map(fn(list) {
      case list.length(list) {
        length if length >= required_amount -> Ok(list)
        _ -> Error(Nil)
      }
    })
    |> result.flatten
    |> result.map(list.take(_, required_amount))
  }

  case result {
    Ok(_) -> result
    _ ->
      case iters {
        0 -> Error(Nil)
        _ -> generate_loop(required_amount, size, iters - 1)
      }
  }
}
