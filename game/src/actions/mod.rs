use crate::actions::actions_list::PlayerActionVariant;
use crate::entities::world::World;

mod actions_list;
mod handlers;

pub trait ActionHandler {
    fn accepts_action(action: &PlayerActionVariant) -> bool;
    fn handle(world: &mut World, action: &PlayerActionVariant);
}
