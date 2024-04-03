pub type Ship {
  Ship(
    id: Int,
    location: ShipLocation,
    target: ShipTarget,
    ownership: ShipOwner,
    onboard_units: Int,
  )
}

pub type ShipLocation {
  ShipLocation(x: Float, y: Float)
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
  location location: ShipLocation,
  target target: ShipTarget,
  ownership ownership: ShipOwner,
  onboard_units onboard_units: Int,
) -> Ship {
  Ship(
    id: id,
    location: location,
    target: target,
    ownership: ownership,
    onboard_units: onboard_units,
  )
}
