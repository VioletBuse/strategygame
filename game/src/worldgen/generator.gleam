import ecs/entities/outposts.{type OutpostType, Outpost}
import ecs/world.{type World, World}
import gleam/float
import gleam/int

pub fn generate_outposts(
  world: World,
  seed: Int,
  min_distance min_distance: Float,
  retries retries: Int,
) -> World {
  let outposts = {
    internal_initial_generate_outposts(world.size, seed, min_distance, retries)
  }

  World(..world, outposts: outposts)
}

type InternalGenerationPoint {
  Point(x: Float, y: Float)
  NoPointGenerated
}

type InternalGenerationGrid {
  Grid(points: List(List(InternalGenerationPoint)), square_size: Float)
}

fn internal_initial_generate_outposts(
  size: Float,
  seed: Int,
  min_distance min_distance: Float,
  retries retries: Int,
) -> List(Outpost) {
  todo
}

fn internal_generate_empty_grid(
  size: Float,
  min_distance: Float,
) -> InternalGenerationGrid {
  let square_count = float.round(size / min_distance)
  let square_size = size / int.to_float(square_count)

  InternalGenerationGrid(
    internal_generate_empty_grid_horizontal_loop(square_count, square_count, []),
    min_distance,
  )
}

fn internal_generate_empty_grid_horizontal_loop(
  num: Int,
  height: Int,
  acc: List(List(InternalGenerationPoint)),
) -> List(List(InternalGenerationPoint)) {
  case num {
    0 -> acc
    _ ->
      internal_generate_empty_grid_horizontal_loop(num - 1, [
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

fn generate_outpost_in_square()
