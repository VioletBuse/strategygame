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

pub fn new_specialist(
  id: Int,
  specialist_type specialist_type: SpecificSpecialist,
  location location: SpecialistLocation,
  ownership ownership: SpecialistOwnership,
) -> Specialist {
  Specialist(
    id: id,
    specialist_type: specialist_type,
    location: location,
    ownership: ownership,
  )
}
