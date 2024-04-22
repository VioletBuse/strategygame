pub opaque type Player {
  Player(id: String)
}

pub opaque type Outpost {
  Outpost(
    id: String,
    outpost_type: OutpostType,
    location: #(Float, Float),
    ownership: OutpostOwnership,
    units: Int,
  )
}

pub type OutpostType {
  Factory
  Generator
  Wreck
  Mine
  Unknown
}

pub type OutpostOwnership {
  OutpostPlayerOwned(player_id: String)
  OutpostUnowned
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

pub type ShipTarget {
  ShipOutpostTarget(outpost_id: String)
  ShipShipTarget(ship_id: String)
  UnknownTarget(heading: Float)
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
