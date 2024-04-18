import ecs/world.{type World}
import ecs/player_actions/action_types.{type PlayerAction, RerouteShip}

pub fn valid(world: World, action: PlayerAction) -> Bool {
  todo
}

pub fn is_of_type(action: PlayerAction) -> Bool {
  case action {
    RerouteShip(_, _, _) -> True
    _ -> False
  }
}

pub fn handler(world: World, action: PlayerAction) -> Result(World, Nil) {
  todo
}
