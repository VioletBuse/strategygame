import gleam/bool.{guard}
import gleam/result
import gleam/list
import ecs/world.{type World, World}
import ecs/entities/ships
import ecs/entities/outposts
import ecs/player_actions/action_types.{type PlayerAction, SendShip}

pub fn valid(world: World, action: PlayerAction) -> Bool {
  let assert SendShip(by_player, from, to, stationed_units, specialists) =
    action

  let player_exists =
    list.any(world.players, fn(player) { player.id == by_player })

  use <- guard(!player_exists, False)

  let starting_outpost_exists =
    list.any(world.outposts, fn(outpost) {
      let is_same_outpost = outpost.id == from
      let is_owned_by_player = case outpost.ownership {
        outposts.PlayerOwned(pid) -> pid == by_player
        _ -> False
      }
      let has_enough_units = outpost.stationed_units >= stationed_units

      is_same_outpost && is_owned_by_player && has_enough_units
    })

  use <- guard(!starting_outpost_exists, False)

  let valid_target = case to {
    ships.ShipTarget(_) -> False
    ships.OutpostTarget(oid) ->
      list.any(world.outposts, fn(outpost) { outpost.id == oid })
  }

  use <- guard(!valid_target, False)

  todo as "finish specialist assignment"

  True
}

pub fn is_of_type(action: PlayerAction) -> Bool {
  case action {
    SendShip(_, _, _, _, _) -> True
    _ -> False
  }
}

pub fn handler(world: World, _action: PlayerAction) -> Result(World, Nil) {
  Ok(world)
}
