use crate::actions::PlayerAction;
use crate::world::world::{World, WorldConfig};

pub fn handle(world: &mut World, config: &WorldConfig, action: &PlayerAction) {
    if let PlayerAction::HireSpecialist {player_id: pid, selection: choice} = action {

    } else {
        panic!("the hire specialist player action handler was called on an unsupported player action")
    }
}
