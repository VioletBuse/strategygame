import gleam/list
import ecs/world.{type World, World}
import ecs/player_actions/action_types.{type PlayerAction}
import ecs/player_actions/handlers/send_ship

type ActionHandlerValidator =
  fn(PlayerAction) -> Bool

type ActionHandler =
  fn(World, PlayerAction) -> Result(World, Nil)

const handlers: List(#(ActionHandlerValidator, ActionHandler)) = [
  #(send_ship.is_of_type, send_ship.handler),
]

pub fn apply_player_actions(
  world: World,
  actions: List(PlayerAction),
) -> Result(World, Nil) {
  player_action_loop(world, actions)
}

fn player_action_loop(
  world: World,
  actions: List(PlayerAction),
) -> Result(World, Nil) {
  case actions {
    [] -> Ok(world)
    [current_action, ..remaining_actions] ->
      case list.find(handlers, fn(h) { h.0(current_action) }) {
        Ok(#(_, handler)) ->
          case handler(world, current_action) {
            Ok(new_world) -> player_action_loop(new_world, remaining_actions)
            _ -> Error(Nil)
          }
        _ -> Error(Nil)
      }
  }
}
