import gleam/list
import ecs/world.{type World}
import ecs/entities/outposts.{type Outpost}

pub fn get(world: World, oid: Int) -> Result(Outpost, Nil) {
  case list.find(world.outposts, fn(outpost) { outpost.id == oid }) {
    Ok(outpost) -> Ok(outpost)
    _ -> Error(Nil)
  }
}
