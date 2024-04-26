use crate::actions::PlayerAction;
use crate::entities::specialist::{Specialist};
use crate::entities::specialist::SpecialistVariant::{Princess, Queen};
use crate::world::world::{World, WorldConfig};

pub fn handle(world: &mut World, config: &WorldConfig, action: &PlayerAction) {
    let PlayerAction::HireSpecialist { player_id, selection } = action;



}
