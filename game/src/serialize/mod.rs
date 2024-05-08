use crate::entities::world::World;

trait Serializer {
    fn deserialize(str: String) -> Result<World, String>;
}
