import ecs/world.{type World}
import ecs/systems/handlers/unit_production

type SystemHandler =
  fn(World) -> Result(World, Nil)

const handlers: List(SystemHandler) = [unit_production.handler]

pub fn apply_systems(world: World) -> Result(World, Nil) {
  apply_systems_loop(world, handlers)
}

fn apply_systems_loop(
  world: World,
  handlers: List(SystemHandler),
) -> Result(World, Nil) {
  case handlers {
    [] -> Ok(world)
    [next_handler, ..rest_handlers] ->
      case next_handler(world) {
        Ok(new_world) -> apply_systems_loop(new_world, rest_handlers)
        _ -> Error(Nil)
      }
  }
}