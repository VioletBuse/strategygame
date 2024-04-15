import gleam/list
import ecs/world.{type World}
import ecs/entities/specialists.{type Specialist}

pub fn get(world: World, sid: Int) -> Result(Specialist, Nil) {
  case list.find(world.specialists, fn(specialist) { specialist.id == sid }) {
    Ok(specialist) -> Ok(specialist)
    _ -> Error(Nil)
  }
}
