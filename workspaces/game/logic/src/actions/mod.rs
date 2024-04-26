mod hire_specialist;

use crate::world::world::{World, WorldConfig};

#[derive(Clone, Debug)]
pub enum PlayerAction {
    HireSpecialist{player_id: String, selection: u8}
}

pub fn handle(world: &mut World, config: &WorldConfig, action: &PlayerAction) {
    match action {
        PlayerAction::HireSpecialist {..} => hire_specialist::handle(world, config, action)
    }
}
