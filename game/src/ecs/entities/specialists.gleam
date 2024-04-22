pub opaque type Specialist {
  Specialist(
    id: Int,
    specialist_type: SpecificSpecialist,
    location: SpecialistLocation,
    ownership: SpecialistOwnership,
  )
}

pub type SpecificSpecialist {
  Queen
  Princess
  Pirate
}

pub type SpecialistLocation {
  OutpostLocation(id: Int)
  ShipLocation(id: Int)
  Unknown
}

pub type SpecialistOwnership {
  PlayerOwned(id: Int)
}
