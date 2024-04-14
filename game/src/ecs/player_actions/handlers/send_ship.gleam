import ecs/world.{type World}
import ecs/player_actions/action_types.{type PlayerAction, SendShip}

pub fn valid(_world: World, _action: PlayerAction) -> Bool {
  True
}

pub fn is_of_type(action: PlayerAction) -> Bool {
  case action {
    SendShip(_, _) -> True
    _ -> False
  }
}

pub fn handler(world: World, _action: PlayerAction) -> Result(World, Nil) {
  Ok(world)
}
