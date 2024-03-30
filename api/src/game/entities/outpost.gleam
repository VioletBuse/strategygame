import ids/nanoid
import game/utils/location.{type Location}

pub type Outpost {
    Outpost(id: String, location: Location)
}

pub fn create_outpost(id: String, location: Location) -> Outpost {
    Outpost(id, location)
}

pub fn generate_outpost_id() -> String {
    nanoid.generate()
}
