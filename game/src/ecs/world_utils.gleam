import gleam/list
import gleam/bool.{guard}
import ecs/world.{type World, ClientWorld, ServerWorld}
import ecs/entities/players
import ecs/entities/outposts
import ecs/entities/ships
import ecs/entities/specialists

fn players_invalid(world: World) -> Bool {
  let more_than_zero_players = !list.is_empty(world.players)

  use <- guard(!more_than_zero_players, False)

  let no_repeated_player_ids =
    list.chunk(world.players, fn(p) { p.id })
    |> list.any(fn(l) { list.length(l) != 1 })

  use <- guard(!no_repeated_player_ids, False)

  True
}

fn outposts_invalid(world: World) -> Bool {
  let no_repeated_outpost_ids =
    list.chunk(world.players, fn(o) { o.id })
    |> list.any(fn(l) { list.length(l) != 1 })

  use <- guard(!no_repeated_outpost_ids, False)

  let outpost_ownership_valid =
    world.outposts
    |> list.map(fn(outpost) {
      case outpost.ownership {
        outposts.Unowned -> True
        outposts.PlayerOwned(pid) -> {
          case
            world.players
            |> list.find(fn(player) { player.id == pid })
          {
            Ok(_) -> True
            _ -> False
          }
        }
      }
    })
    |> list.any(fn(v) { !v })

  use <- guard(!outpost_ownership_valid, False)

  let outpost_unit_staffing_valid =
    world.outposts
    |> list.map(fn(outpost) { outpost.stationed_units >= 0 })
    |> list.any(fn(v) { !v })

  use <- guard(!outpost_unit_staffing_valid, False)

  True
}

fn ships_invalid(world: World) -> Bool {
  let no_repeated_ship_ids =
    list.chunk(world.ships, fn(s) { s.id })
    |> list.any(fn(l) { list.length(l) != 1 })

  use <- guard(!no_repeated_ship_ids, False)

  let ship_targeting_valid =
    world.ships
    |> list.map(fn(ship) {
      case ship.target {
        ships.OutpostTarget(oid) ->
          case list.find(world.outposts, fn(o) { o.id == oid }) {
            Ok(_) -> True
            _ -> False
          }
        ships.ShipTarget(sid) ->
          case
            list.find(world.ships, fn(s) { s.id == sid && s.id != ship.id })
          {
            Ok(_) -> True
            _ -> False
          }
      }
    })
    |> list.any(fn(v) { !v })

  use <- guard(!ship_targeting_valid, False)

  let ship_ownership_valid =
    world.ships
    |> list.map(fn(ship) {
      case ship.ownership {
        ships.Unowned -> True
        ships.PlayerOwned(pid) ->
          case list.find(world.players, fn(p) { p.id == pid }) {
            Ok(_) -> True
            _ -> False
          }
      }
    })
    |> list.any(fn(v) { !v })

  use <- guard(!ship_ownership_valid, False)

  let ship_unit_count_valid =
    world.ships
    |> list.map(fn(s) { s.onboard_units >= 0 })
    |> list.any(fn(v) { !v })

  use <- guard(!ship_unit_count_valid, False)

  True
}

fn specialists_invalid(world: World) -> Bool {
  let no_repeated_specialist_ids =
    world.specialists
    |> list.chunk(fn(s) { s.id })
    |> list.any(fn(l) { list.length(l) != 1 })

  use <- guard(!no_repeated_specialist_ids, False)

  let specialist_ownership_valid =
    world.specialists
    |> list.map(fn(spec) {
      case
        list.find(world.players, fn(player) { player.id == spec.ownership.id })
      {
        Ok(_) -> True
        _ -> False
      }
    })
    |> list.any(fn(v) { !v })

  use <- guard(!specialist_ownership_valid, False)

  let specialist_location_valid =
    world.specialists
    |> list.map(fn(specialist) {
      case specialist.location {
        specialists.OutpostLocation(oid) ->
          case list.find(world.outposts, fn(o) { o.id == oid }) {
            Ok(_) -> True
            _ -> False
          }
        specialists.ShipLocation(sid) ->
          case list.find(world.ships, fn(s) { s.id == sid }) {
            Ok(_) -> True
            _ -> False
          }
        _ -> True
      }
    })
    |> list.any(fn(v) { !v })

  use <- guard(!specialist_location_valid, False)

  True
}

pub fn validate(world: World) -> Bool {
  use <- guard(players_invalid(world), False)
  use <- guard(outposts_invalid(world), False)
  use <- guard(ships_invalid(world), False)
  use <- guard(specialists_invalid(world), False)

  True
}

pub fn set_tick(world: World, tick: Int) -> World {
  todo
}

pub fn write_players(world: World, players: List(players.Player)) -> World {
  todo
}

pub fn write_outposts(world: World, outposts: List(outposts.Outpost)) -> World {
  todo
}

pub fn write_ships(world: World, ships: List(ships.Ship)) -> World {
  todo
}

pub fn write_specialists(
  world: World,
  specs: List(specialists.Specialist),
) -> World {
  todo
}
