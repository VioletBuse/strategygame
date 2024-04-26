use crate::entities::outpost::Owner::{PlayerOwned, Unowned};
use crate::entities::outpost::Variant::{Factory, Generator};
use crate::entities::player::Player;
use crate::world::world::World;

#[derive(Clone, Debug)]
pub enum Variant {
    Generator,
    Factory,
    Mine,
    Wreck,
    Unknown,
}

impl Variant {

}

#[derive(Clone, Debug)]
pub enum Owner {
    PlayerOwned { owner_id: String },
    Unowned,
}

#[derive(Clone, Debug)]
pub struct Outpost {
    pub id: String,
    pub variant: Variant,
    pub x: f32,
    pub y: f32,
    pub owner: Owner,
    pub units: u32,
}

impl Outpost {
    fn get_owner(&self, world: &World) -> Option<&Player> {
        match &self.owner {
            Owner::PlayerOwned { owner_id: id } =>
                world.players.iter().find(|player| player.id == id.as_str()),
            Owner::Unowned => None
        }
    }
    fn set_owner(& mut self, new_owner: &Player) {
        self.owner = PlayerOwned {owner_id: new_owner.id.to_owned()}
    }
    fn set_unowned(& mut self) {
        self.owner = Unowned
    }
}
