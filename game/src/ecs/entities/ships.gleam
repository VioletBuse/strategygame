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
  PlayerOwned(id: Int)
  Unowned
}
