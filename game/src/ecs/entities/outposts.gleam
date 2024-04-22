pub opaque type Outpost {
  Outpost(
    id: Int,
    outpost_type: OutpostType,
    location: OutpostLocation,
    ownership: OutpostOwnership,
    stationed_units: Int,
  )
}

pub type OutpostType {
  Factory(production_offset: Int)
  Generator
  Wreck
  Mine
  Unknown(unit_production: Int, unit_supply: Int)
}

pub type OutpostLocation {
  OutpostLocation(x: Float, y: Float)
}

pub type OutpostOwnership {
  PlayerOwned(id: Int)
  Unowned
}
