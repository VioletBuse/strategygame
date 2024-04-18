import ecs/world.{type World}
import ecs/world_utils
import ecs/systems/handlers/princess_takeover
import ecs/systems/handlers/death
import ecs/systems/handlers/unit_maxima
import ecs/systems/handlers/unit_production

type SystemHandler =
  fn(World) -> Result(World, Nil)

const handlers: List(SystemHandler) = [
  princess_takeover.handler,
  death.handler,
  unit_production.handler,
  unit_maxima.handler,
]

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
        Ok(new_world) ->
          case world_utils.validate(new_world) {
            True -> apply_systems_loop(new_world, rest_handlers)
            False -> Error(Nil)
          }
        _ -> Error(Nil)
      }
  }
}
