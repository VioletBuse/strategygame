import gleam/io
import gleam/result
import gleam/list
import gleam/dict
// import worldgen/poisson.{poisson}
import worldgen/world

pub fn main() {
  world.generate_world(8, 2, 3, 6, 0.5)
  // |> result.map(list.length)
  |> result.map(list.group(_, fn(v) {
    case v {
      #(world.OwnedOutpost(_, _, id, _), _, _) -> id
      #(world.UnownedOutpost(_, _), _, _) -> -1
    }
  }))
  |> result.map(dict.to_list)
  |> result.map(io.debug)
}
