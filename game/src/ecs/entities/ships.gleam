pub type Ship {
  Ship(
    id: Int,
    source: ShipSource,
    target: ShipTarget,
    ownership: ShipOwner,
    onboard_units: Int,
  )
}

pub type ShipSource {
  OutpostSource(id: Int)
}

pub type ShipTarget {
  OutpostTarget(id: Int)
  ShipTarget(id: Int)
}

pub type ShipOwner {
  Player(id: Int)
  Unowned
}

pub fn new_ship(
  id: Int,
  source source: ShipSource,
  target target: ShipTarget,
  ownership ownership: ShipOwner,
  onboard_units onboard_units: Int,
) -> Ship {
  Ship(
    id: id,
    source: source,
    target: target,
    ownership: ownership,
    onboard_units: onboard_units,
  )
}
