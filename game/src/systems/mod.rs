use crate::entities::world::World;

mod handlers;

pub trait SystemHandler {
    fn handle(world: &mut World);
}
