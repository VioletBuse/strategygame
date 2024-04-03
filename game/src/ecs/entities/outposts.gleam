pub type Outpost {
  Outpost(
    id: Int,
    outpost_type: OutpostType,
    location: OutpostLocation,
    ownership: OutpostOwnership,
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

pub fn new(
  id: Int,
  outpost_type outpost_type: OutpostType,
  location location: OutpostLocation,
  ownership ownership: OutpostOwnership,
) -> Outpost {
  Outpost(
    id: id,
    outpost_type: outpost_type,
    location: location,
    ownership: ownership,
  )
}
