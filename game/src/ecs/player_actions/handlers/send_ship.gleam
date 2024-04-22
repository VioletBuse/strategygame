import gleam/bool.{guard}
import gleam/int
import gleam/result
import gleam/list
import ecs/world.{type World, World}
import ecs/entities/ships
import ecs/entities/outposts
import ecs/entities/specialists
import ecs/utils/player
import ecs/utils/outpost
import ecs/utils/ship
import ecs/utils/specialist
import ecs/player_actions/action_types.{type PlayerAction, SendShip}

fn get_specs(
  world: World,
  spec_ids: List(Int),
) -> Result(List(specialists.Specialist), Nil) {
  list.map(spec_ids, specialist.get(world, _))
  |> list.fold(Ok([]), fn(acc, spec_res) {
    case acc {
      Error(_) -> Error(Nil)
      Ok(list) ->
        case spec_res {
          Ok(specialist) -> Ok([specialist, ..list])
          _ -> Error(Nil)
        }
    }
  })
}

pub fn valid(world: World, action: PlayerAction) -> Bool {
  let assert SendShip(by, from, to, units, specialists) = action

  let player_exists =
    player.get(world, by)
    |> result.is_ok

  use <- guard(!player_exists, False)

  let source_exists =
    outpost.get(world, from)
    |> result.is_ok

  use <- guard(!source_exists, False)

  let target_exists = case to {
    ships.OutpostTarget(oid) ->
      outpost.get(world, oid)
      |> result.is_ok
    ships.ShipTarget(sid) ->
      ship.get_ship(world, sid)
      |> result.is_ok
  }

  use <- guard(!target_exists, False)

  let enough_stationed_units = case outpost.get(world, from) {
    Ok(from_outpost) -> from_outpost.stationed_units >= units
    _ -> False
  }

  use <- guard(!enough_stationed_units, False)

  let specialists_available = case get_specs(world, specialists) {
    Ok(spec_list) ->
      list.fold(spec_list, True, fn(acc, specialist) {
        case acc {
          False -> False
          True ->
            case specialist.location {
              specialists.OutpostLocation(oid) -> oid == from
              _ -> False
            }
        }
      })
    _ -> False
  }

  use <- guard(!specialists_available, False)

  let pirate_in_specs = case get_specs(world, specialists) {
    Ok(spec_list) ->
      list.any(spec_list, fn(specialist) {
        case specialist.specialist_type {
          specialists.Pirate -> True
          _ -> False
        }
      })
    _ -> False
  }

  use <- guard(!pirate_in_specs, False)

  True
}

pub fn is_of_type(action: PlayerAction) -> Bool {
  case action {
    SendShip(_, _, _, _, _) -> True
    _ -> False
  }
}

pub fn handler(world: World, action: PlayerAction) -> Result(World, Nil) {
  let action_is_doable = valid(world, action)

  use <- guard(!action_is_doable, Error(Nil))

  let assert SendShip(
    player_id,
    from_outpost_id,
    target,
    unit_count,
    specialist_ids,
  ) = action

  use player <- result.try(player.get(world, player_id))

  use originating_outpost <- result.try(outpost.get(world, from_outpost_id))

  let new_ship_id = int.random(1_000_000_000)
  let new_ship_location =
    ships.ShipLocation(
      originating_outpost.location.x,
      originating_outpost.location.y,
    )
  let new_ship_target = target
  let new_ship_owner = ships.PlayerOwned(player_id)
  let new_ship_onboard_units = unit_count

  let new_ship =
    ships.Ship(
      new_ship_id,
      new_ship_location,
      new_ship_target,
      new_ship_owner,
      new_ship_onboard_units,
    )

  let updated_outpost_stationed_units =
    originating_outpost.stationed_units - unit_count
  let updated_outpost =
    outposts.Outpost(
      ..originating_outpost,
      stationed_units: updated_outpost_stationed_units,
    )

  let new_specialist_location = specialists.ShipLocation(new_ship_id)

  use specialists <- result.try(get_specs(world, specialist_ids))

  let updated_specialists =
    list.map(specialists, fn(specialist) {
      specialists.Specialist(..specialist, location: new_specialist_location)
    })

  let new_world =
    world
    |> ship.add_ship(new_ship)
    |> outpost.update_outpost(updated_outpost)
    |> list.fold(updated_specialists, _, specialist.update_specialist)

  Ok(new_world)
}
