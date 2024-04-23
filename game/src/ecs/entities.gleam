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

pub fn new_unknown(location: #(Float, Float), owner: Option(String)) -> Outpost {
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
