use crate::entities::outpost::OutpostOwner::{OutpostPlayerOwned, OutpostUnowned};
use crate::entities::outpost::OutpostVariant::{Unknown, Wreck, Mine, Factory, Generator};
use crate::entities::player::Player;
use crate::entities::specialist::Specialist;
use crate::world::world::World;

#[derive(Clone, Debug)]
pub enum OutpostVariant {
    Generator,
    Factory,
    Mine,
    Wreck,
    Unknown,
}

impl OutpostVariant {
    pub fn is_gen(&self) -> bool {
        match self {
            Generator => true,
            _ => false
        }
    }
    pub fn is_fac(&self) -> bool {
        match self {
            Factory => true,
            _ => false
        }
    }
    pub fn is_mine(&self) -> bool {
        match self {
            Mine => true,
            _ => false
        }
    }
    pub fn is_wreck(&self) -> bool {
        match self {
            Wreck => true,
            _ => false
        }
    }
    pub fn is_unknown(&self) -> bool {
        match self {
            Unknown => true,
            _ => false
        }
    }
}

#[derive(Clone, Debug)]
pub enum OutpostOwner {
    OutpostPlayerOwned { owner_id: String },
    OutpostUnowned,
}

impl OutpostOwner {
    pub fn new_player_owned(outpost: &Player) -> OutpostOwner {
        OutpostPlayerOwned { owner_id: outpost.id.clone() }
    }
    pub fn new_unowned() -> OutpostOwner {
        OutpostUnowned
    }
    pub fn is_player_owned(&self) -> bool {
        match self {
            OutpostPlayerOwned { .. } => true,
            _ => false
        }
    }
    pub fn is_unowned(&self) -> bool {
        match self {
            OutpostUnowned => true,
            _ => false
        }
    }
    pub fn get_owner_id(&self) -> Option<String> {
        match self {
            OutpostPlayerOwned { owner_id } => Some(owner_id.clone()),
            _ => None
        }
    }
    pub fn get_owning_player(&self, world: &World) -> Option<&Player> {
        match self {
            OutpostPlayerOwned { owner_id } => {
                world.players.iter()
                    .find(|player| player.id == owner_id.to_string())
            }
            OutpostUnowned => None
        }
    }
    pub fn set_player_owned(&mut self, outpost: &Player) {
        match self {
            OutpostPlayerOwned { owner_id: oid } => {
                *oid = outpost.id.clone()
            }
            OutpostUnowned => {
                *self = OutpostPlayerOwned { owner_id: outpost.id.clone() }
            }
        }
    }
    pub fn set_unowned(&mut self) {
        *self = OutpostUnowned
    }
}

#[derive(Clone, Debug)]
pub struct Outpost {
    pub id: String,
    pub variant: OutpostVariant,
    pub x: f32,
    pub y: f32,
    pub owner: OutpostOwner,
    pub units: u32,
}

impl Outpost {
    pub fn stationed_specialists(&self, world: &World) -> Vec<&Specialist> {
        world.specialists.iter()
            .filter(|&&spec|
                spec.location.get_outpost_location_id() == Some(self.id.clone()) &&
                    spec.owner.get_owner_id() == self.owner.get_owner_id())
            .collect()
    }
    pub fn jailed_specialists(&self, world: &World) -> Vec(&Specialist) {
        world.specialists.iter()
            .filter(|&&spec| spec.location.get_outpost_location_id() == Some(self.id.clone()) &&
                spec.owner.get_owner_id() != self.owner.get_owner_id())
            .collect()
    }
}
