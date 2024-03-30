import ids/nanoid
import game/utils/location.{type Location}

pub type Outpost {
    Factory(id: String, location: Location, units: Int)
    Generator(id: String, location: Location, units: Int)
    Mine(id: String, location: Location, units: Int)
    Wreck(id: String, location: Location)
}

pub fn create_factory(id: String, location: Location) -> Outpost {
    Factory(id, location, 0)
}

pub fn create_generator(id: String, location: Location) -> Outpost {
    Generator(id, location, 0)
}

pub fn advance_tick(outpost: Outpost) -> Outpost {
    case outpost {
        Wreck(id, location) -> Wreck(id, location)
        Mine(id, location, units) -> Mine(id, location, units)
        Generator(id, location, units) -> Generator(id, location, units)
        Factory(id, location, units) -> Factory(id, location, units + 10)
    }
}

pub fn generate_outpost_id() -> String {
    nanoid.generate()
}
