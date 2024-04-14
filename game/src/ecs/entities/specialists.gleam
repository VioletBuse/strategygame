pub type Specialist {
  Specialist(
    id: Int,
    specialist_type: SpecificSpecialist,
    location: SpecialistLocation,
    ownership: SpecialistOwnership,
  )
}

pub type SpecificSpecialist {
  Queen
}

pub type SpecialistLocation {
  OutpostLocation(id: Int)
  ShipLocation(id: Int)
}

pub type SpecialistOwnership {
  Player(id: Int)
}
