use crate::entities::outpost::Outpost;
use crate::entities::player::Player;
use crate::entities::ship::ShipOwner::{ShipPlayerOwned, ShipUnowned};
use crate::entities::ship::ShipTarget::{ShipOutpostTarget, ShipShipTarget, ShipUnknownTarget};
use crate::entities::specialist::Specialist;
use crate::world::world::World;

#[derive(Clone, Debug)]
pub enum ShipOwner {
    ShipPlayerOwned { player_id: String },
    ShipUnowned,
}

impl ShipOwner {
    pub fn new_player_owner(player: &Player) -> ShipOwner {
        ShipPlayerOwned { player_id: player.id.clone() }
    }
    pub fn new_unowned() -> ShipOwner {
        ShipUnowned
    }
    pub fn is_player_owned(&self) -> bool {
        match self {
            ShipPlayerOwned { .. } => true,
            _ => false
        }
    }
    pub fn is_unowned(&self) -> bool {
        match self {
            ShipUnowned => true,
            _ => false
        }
    }
    pub fn get_owner_id(&self) -> Option<String> {
        match self {
            ShipPlayerOwned { player_id } => Some(player_id.to_string()),
            _ => None
        }
    }
    pub fn get_owning_player<'a>(&'a self, world: &'a World) -> Option<&Player> {
        match self {
            ShipPlayerOwned { player_id } => {
                world.players.iter()
                    .find(|player| player.id == player_id.to_string())
            }
            _ => None
        }
    }
    pub fn set_player_owned(&mut self, player: &Player) {
        *self = ShipPlayerOwned { player_id: player.id.clone() }
    }
    pub fn set_unowned(&mut self) {
        *self = ShipUnowned
    }
}

#[derive(Clone, Debug)]
pub enum ShipTarget {
    ShipOutpostTarget { outpost_id: String },
    ShipShipTarget { ship_id: String },
    ShipUnknownTarget { heading: f32 },
}

impl ShipTarget {
    pub fn new_outpost_target(outpost: &Outpost) -> ShipTarget {
        ShipOutpostTarget { outpost_id: outpost.id.clone() }
    }
    pub fn new_ship_target(ship: &Ship) -> ShipTarget {
        ShipShipTarget { ship_id: ship.id.clone() }
    }
    pub fn new_unknown_target(heading: f32) -> ShipTarget {
        ShipUnknownTarget { heading }
    }
    pub fn is_outpost(&self) -> bool {
        match self {
            ShipOutpostTarget { .. } => true,
            _ => false
        }
    }
    pub fn is_ship(&self) -> bool {
        match self {
            ShipShipTarget { .. } => true,
            _ => false
        }
    }
    pub fn is_unknown(&self) -> bool {
        match self {
            ShipUnknownTarget { .. } => true,
            _ => false
        }
    }
    pub fn get_outpost_id(&self) -> Option<String> {
        match self {
            ShipOutpostTarget { outpost_id } => Some(outpost_id.clone()),
            _ => None
        }
    }
    pub fn get_ship_id(&self) -> Option<String> {
        match self {
            ShipShipTarget { ship_id } => Some(ship_id.clone()),
            _ => None
        }
    }
    pub fn get_outpost_target<'a>(&'a self, world: &'a World) -> Option<&Outpost> {
        match self {
            ShipOutpostTarget { outpost_id } => {
                world.outposts.iter()
                    .find(|outpost| outpost.id == outpost_id.to_string())
            }
            _ => None
        }
    }
    pub fn get_ship_target<'a>(&'a self, world: &'a World) -> Option<&Ship> {
        match self {
            ShipShipTarget { ship_id } => {
                world.ships.iter()
                    .find(|ship| ship.id == ship_id.to_string())
            }
            _ => None
        }
    }
    pub fn get_heading(&self) -> Option<&f32> {
        match self {
            ShipUnknownTarget { heading } => Some(heading),
            _ => None
        }
    }
    pub fn set_outpost_target(&mut self, outpost: &Outpost) {
        *self = ShipOutpostTarget { outpost_id: outpost.id.clone() }
    }
    pub fn set_ship_target(&mut self, ship: &Ship) {
        *self = ShipShipTarget { ship_id: ship.id.clone() }
    }
    pub fn set_unknown_target(&mut self, heading: f32) {
        *self = ShipUnknownTarget { heading }
    }
}

#[derive(Clone, Debug)]
pub struct Ship {
    pub id: String,
    pub x: f32,
    pub y: f32,
    pub owner: ShipOwner,
    pub target: ShipTarget,
    pub units: u32,
}

impl Ship {
    pub fn get_specialists<'a>(&'a self, world: &'a World) -> Vec<&Specialist> {
        world.specialists.iter()
            .filter(|spec|
                spec.location.get_ship_location_id() == Some(self.id.clone()) &&
                    spec.owner.get_owner_id() == self.owner.get_owner_id())
            .collect()
    }
    pub fn get_jailed_specialists<'a>(&'a self, world: &'a World) -> Vec<&Specialist> {
        world.specialists.iter()
            .filter(|spec|
                spec.location.get_ship_location_id() == Some(self.id.clone()) &&
                    spec.owner.get_owner_id() != self.owner.get_owner_id())
            .collect()
    }
}
