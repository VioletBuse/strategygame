pub type Outpost {
  Outpost(id: Int, outpost_type: OutpostType, ownership: OutpostOwnership)
}

pub type OutpostType {
  Factory
  Generator
  Wreck
  Mine
  Unknown
}

pub type OutpostOwnership {
  Player(id: Int)
  Unowned
}

pub fn new(
  id: Int,
  outpost_type outpost_type: OutpostType,
  ownership ownership: OutpostOwnership,
) -> Outpost {
  Outpost(id: id, outpost_type: outpost_type, ownership: ownership)
}
