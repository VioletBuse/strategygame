import gleam/bool.{guard}
import gleam/option.{type Option, None, Some}
import gleam/list
import idgen

pub opaque type Player {
  Player(id: String)
}

pub fn new_player() -> Player {
  idgen.new(32)
  |> Player
}

pub fn list_owned_outposts(world: World, player: Player) -> List(Outpost) {
  list.filter(world.outposts, fn(outpost) {
    case outpost.owner {
      OutpostPlayerOwned(outpost_player_id) -> outpost_player_id == player.id
      _ -> False
    }
  })
}

pub fn list_owned_ships(world: World, player: Player) -> List(Ship) {
  list.filter(world.ships, fn(ship) {
    case ship.owner {
      ShipPlayerOwned(ship_player_id) -> ship_player_id == player.id
      _ -> False
    }
  })
}

pub fn list_owned_specialists(world: World, player: Player) -> List(Specialist) {
  list.filter(world.specialists, fn(spec) {
    case spec.owner {
      SpecPlayerOwned(spec_player_id) -> spec_player_id == player.id
      _ -> False
    }
  })
}

pub opaque type Outpost {
  Outpost(
    id: String,
    outpost_type: OutpostType,
    location: #(Float, Float),
    owner: OutpostOwnership,
    units: Int,
  )
}

pub fn new_factory(location: #(Float, Float), owner: Option(String)) -> Outpost {
  let id = idgen.new(32)
  let ownership = case owner {
    Some(id) -> OutpostPlayerOwned(id)
    None -> OutpostUnowned
  }

  Outpost(
    id: id,
    outpost_type: Factory,
    location: location,
    owner: ownership,
    units: 0,
  )
}

pub fn new_generator(
  location: #(Float, Float),
  owner: Option(String),
) -> Outpost {
  let id = idgen.new(32)
  let ownership = case owner {
    Some(id) -> OutpostPlayerOwned(id)
    None -> OutpostUnowned
  }

  Outpost(
    id: id,
    outpost_type: Generator,
    location: location,
    owner: ownership,
    units: 0,
  )
}

pub fn new_unknown_outpost(
  location: #(Float, Float),
  owner: Option(String),
) -> Outpost {
  let id = idgen.new(32)
  let ownership = case owner {
    Some(id) -> OutpostPlayerOwned(id)
    None -> OutpostUnowned
  }

  Outpost(
    id: id,
    outpost_type: Unknown,
    location: location,
    owner: ownership,
    units: 0,
  )
}

pub fn to_mine(outpost: Outpost, units_required: Int) -> Result(Outpost, Nil) {
  use <- guard(outpost.units < units_required, Error(Nil))

  case outpost.outpost_type {
    Factory | Generator ->
      Ok(
        Outpost(
          ..outpost,
          outpost_type: Mine,
          units: outpost.units
          - units_required,
        ),
      )
    _ -> Error(Nil)
  }
}

pub fn to_wreck(outpost: Outpost) -> Outpost {
  Outpost(..outpost, outpost_type: Wreck)
}

pub type OutpostType {
  Factory
  Generator
  Wreck
  Mine
  Unknown
}

pub fn is_factory(outpost: Outpost) -> Bool {
  case outpost.outpost_type {
    Factory -> True
    _ -> False
  }
}

pub fn is_generator(outpost: Outpost) -> Bool {
  case outpost.outpost_type {
    Generator -> True
    _ -> False
  }
}

pub fn is_wreck(outpost: Outpost) -> Bool {
  case outpost.outpost_type {
    Wreck -> True
    _ -> False
  }
}

pub fn is_mine(outpost: Outpost) -> Bool {
  case outpost.outpost_type {
    Mine -> True
    _ -> False
  }
}

pub fn is_outpost_type_unknown(outpost: Outpost) -> Bool {
  case outpost.outpost_type {
    Unknown -> True
    _ -> False
  }
}

pub type OutpostOwnership {
  OutpostPlayerOwned(player_id: String)
  OutpostUnowned
}

pub fn is_outpost_owned(outpost: Outpost) -> Bool {
  case outpost.owner {
    OutpostPlayerOwned(_) -> True
    _ -> False
  }
}

pub fn is_outpost_owned_by_player(outpost: Outpost, player: Player) -> Bool {
  case outpost.owner {
    OutpostPlayerOwned(outpost_player_id) -> outpost_player_id == player.id
    _ -> False
  }
}

pub fn is_outpost_owned_by_player_id(
  outpost: Outpost,
  player_id: String,
) -> Bool {
  case outpost.owner {
    OutpostPlayerOwned(outpost_player_id) -> outpost_player_id == player_id
    _ -> False
  }
}

pub fn get_outpost_owner(world: World, outpost: Outpost) -> Result(Player, Nil) {
  case outpost.owner {
    OutpostPlayerOwned(player_id) ->
      list.find(world.players, fn(player) { player.id == player_id })
    OutpostUnowned -> Error(Nil)
  }
}

pub fn set_outpost_player_owned(outpost: Outpost, player: Player) -> Outpost {
  Outpost(..outpost, owner: OutpostPlayerOwned(player.id))
}

pub fn set_outpost_unowned(outpost: Outpost) -> Outpost {
  Outpost(..outpost, owner: OutpostUnowned)
}

pub fn outpost_list_targeting_ships(
  world: World,
  outpost: Outpost,
) -> List(Ship) {
  list.filter(world.ships, ship_targeting_outpost(_, outpost))
}

pub opaque type Ship {
  Ship(
    id: String,
    location: #(Float, Float),
    target: ShipTarget,
    owner: ShipOwner,
    units: Int,
  )
}

pub fn new_ship(
  location: #(Float, Float),
  target: ShipTarget,
  owner: Option(String),
  units: Int,
) -> Ship {
  let id = idgen.new(32)
  let owner = case owner {
    Some(owner_id) -> ShipPlayerOwned(owner_id)
    None -> ShipUnowned
  }

  Ship(id, location, target, owner, units)
}

pub type ShipTarget {
  ShipOutpostTarget(outpost_id: String)
  ShipShipTarget(ship_id: String)
  UnknownTarget(heading: Float)
}

pub fn new_outpost_target(outpost: Outpost) -> ShipTarget {
  ShipOutpostTarget(outpost.id)
}

pub fn new_ship_target(ship: Ship) -> ShipTarget {
  ShipShipTarget(ship.id)
}

pub fn new_ship_unknown_target(heading: Float) -> ShipTarget {
  UnknownTarget(heading)
}

pub fn ship_target_outpost(ship: Ship) -> Bool {
  case ship.target {
    ShipOutpostTarget(_) -> True
    _ -> False
  }
}

pub fn ship_targeting_outpost(ship: Ship, outpost: Outpost) -> Bool {
  case ship.target {
    ShipOutpostTarget(target_id) if target_id == outpost.id -> True
    _ -> False
  }
}

pub fn ship_target_ship(ship: Ship) -> Bool {
  case ship.target {
    ShipShipTarget(_) -> True
    _ -> False
  }
}

pub fn ship_targeting_ship(ship: Ship, target: Ship) -> Bool {
  case ship.target {
    ShipShipTarget(target_id) if target_id == target.id -> True
    _ -> False
  }
}

pub fn ship_target_unknown(ship: Ship) -> Bool {
  case ship.target {
    UnknownTarget(_) -> True
    _ -> False
  }
}

pub fn ship_get_targeted_outpost(
  world: World,
  ship: Ship,
) -> Result(Outpost, Nil) {
  case ship.target {
    ShipOutpostTarget(outpost_id) ->
      list.find(world.outposts, fn(outpost) { outpost.id == outpost_id })
    _ -> Error(Nil)
  }
}

pub fn ship_get_targeted_ship(world: World, ship: Ship) -> Result(Ship, Nil) {
  case ship.target {
    ShipShipTarget(ship_id) ->
      list.find(world.ships, fn(ship) { ship.id == ship_id })
    _ -> Error(Nil)
  }
}

pub fn ship_get_unknown_target_heading(
  _world: World,
  ship: Ship,
) -> Result(Float, Nil) {
  case ship.target {
    UnknownTarget(heading) -> Ok(heading)
    _ -> Error(Nil)
  }
}

pub fn ship_retarget_to_outpost(ship: Ship, outpost: Outpost) -> Ship {
  Ship(..ship, target: ShipOutpostTarget(outpost.id))
}

pub fn ship_retarget_to_ship(ship: Ship, target_ship: Ship) -> Ship {
  Ship(..ship, target: ShipShipTarget(target_ship.id))
}

pub type ShipOwner {
  ShipPlayerOwned(player_id: String)
  ShipUnowned
}

pub fn ship_is_player_owned(ship: Ship) -> Bool {
  case ship.owner {
    ShipPlayerOwned(_) -> True
    _ -> False
  }
}

pub fn ship_is_owned_by_player(ship: Ship, player: Player) -> Bool {
  case ship.owner {
    ShipPlayerOwned(player_id) if player_id == player.id -> True
    _ -> False
  }
}

pub fn ship_is_unowned(ship: Ship) -> Bool {
  case ship.owner {
    ShipUnowned -> True
    _ -> False
  }
}

pub fn ship_set_unowned(ship: Ship) -> Ship {
  Ship(..ship, owner: ShipUnowned)
}

pub fn ship_set_owner_player(ship: Ship, player: Player) -> Ship {
  Ship(..ship, owner: ShipPlayerOwned(player.id))
}

pub fn ship_get_owning_player(world: World, ship: Ship) -> Result(Player, Nil) {
  case ship.owner {
    ShipPlayerOwned(owner_id) ->
      list.find(world.players, fn(player) { player.id == owner_id })
    _ -> Error(Nil)
  }
}

pub fn ship_get_targeting_ships(world: World, ship: Ship) -> List(Ship) {
  list.filter(world.ships, ship_targeting_ship(_, ship))
}

pub opaque type Specialist {
  Specialist(
    id: String,
    specialist_type: SpecialistType,
    location: SpecialistLocation,
    owner: SpecialistOwnership,
  )
}

pub type SpecialistType {
  Queen
  Princess
  Pirate
  Helmsman
}

pub type SpecialistLocation {
  SpecOutpostLocation(outpost_id: String)
  SpecShipLocation(ship_id: String)
  SpecUnknownLocation
}

pub type SpecialistOwnership {
  SpecPlayerOwned(player_id: String)
  SpecUnowned
}

pub opaque type GameMode {
  Standard
  Quickplay
}

pub opaque type World {
  World(
    world_type: WorldType,
    current_tick: Int,
    size: Int,
    players: List(Player),
    outposts: List(Outpost),
    ships: List(Ship),
    specialists: List(Specialist),
    config: WorldConfig,
  )
}

pub type WorldConfig {
  WorldConfig
}

pub type WorldType {
  ServerWorld
  ClientWorld(for_player_id: String)
}
