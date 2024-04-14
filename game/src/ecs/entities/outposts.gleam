pub type Outpost {
  Outpost(
    id: Int,
    outpost_type: OutpostType,
    location: OutpostLocation,
    ownership: OutpostOwnership,
    stationed_units: Int,
  )
}

pub type OutpostType {
  Factory
  Generator
  Wreck
  Mine
  Unknown
}

pub type OutpostLocation {
  OutpostLocation(x: Float, y: Float)
}

pub type OutpostOwnership {
  Player(id: Int)
  Unowned
}
