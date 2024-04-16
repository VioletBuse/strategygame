import gleam/result
import ecs/world.{type World}
import ecs/player_actions/action_types.{type PlayerAction}
import ecs/player_actions/main as player_actions
import ecs/systems/main as systems

pub fn run_tick(world: World, actions: List(PlayerAction)) -> Result(World, Nil) {
  use world_after_actions <- result.try(player_actions.apply_player_actions(
    world,
    actions,
  ))
  use world_after_systems <- result.try(systems.apply_systems(
    world_after_actions,
  ))

  Ok(world_after_systems)
}
