import gleam/list
import ecs/world.{type World, World}
import ecs/world_utils
import ecs/player_actions/action_types.{type PlayerAction}
import ecs/player_actions/handlers/send_ship

type ActionHandlerValidator =
  fn(PlayerAction) -> Bool

type ActionStateValidator =
  fn(World, PlayerAction) -> Bool

type ActionHandler =
  fn(World, PlayerAction) -> Result(World, Nil)

const handlers: List(
  #(ActionHandlerValidator, ActionStateValidator, ActionHandler, Int),
) = [#(send_ship.is_of_type, send_ship.valid, send_ship.handler, 3)]

pub fn apply_player_actions(
  world: World,
  actions: List(PlayerAction),
) -> Result(World, Nil) {
  player_action_loop(world, actions)
}

fn retry_action_handler(
  world: World,
  action: PlayerAction,
  handler: ActionHandler,
  retries: Int,
) -> Result(World, Nil) {
  case retries {
    0 -> Error(Nil)
    _ ->
      case handler(world, action) {
        Ok(world) -> Ok(world)
        _ -> retry_action_handler(world, action, handler, retries - 1)
      }
  }
}

fn player_action_loop(
  world: World,
  actions: List(PlayerAction),
) -> Result(World, Nil) {
  case actions {
    [] -> Ok(world)
    [current_action, ..remaining_actions] ->
      case list.find(handlers, fn(h) { h.0(current_action) }) {
        Ok(#(_, _validator, handler, retries)) ->
          case retry_action_handler(world, current_action, handler, retries) {
            Ok(new_world) ->
              case world_utils.validate(new_world) {
                True -> player_action_loop(new_world, remaining_actions)
                False -> Error(Nil)
              }
            _ -> Error(Nil)
          }
        _ -> Error(Nil)
      }
  }
}
