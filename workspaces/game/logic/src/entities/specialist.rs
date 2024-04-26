use std::collections::LinkedList;
use crate::entities::outpost::Outpost;
use crate::entities::player::Player;
use crate::entities::ship::Ship;
use crate::entities::specialist::SpecialistLocation::{SpecialistOutpostLocation, SpecialistShipLocation};
use crate::entities::specialist::SpecialistOwner::{SpecPlayerOwned, SpecUnowned};
use crate::entities::specialist::SpecialistVariant::{Navigator, Pirate, Princess, Queen};
use crate::world::world::World;

#[derive(Clone, Debug)]
pub enum SpecialistVariant {
    Queen { upcoming_hires: LinkedList<Vec<SpecialistVariant>>, hires_available: u16, ticks_since_update: u32 },
    Princess,
    Navigator,
    Pirate,
}

impl SpecialistVariant {
    fn new_queen() -> SpecialistVariant {
        Queen { upcoming_hires: LinkedList::new(), hires_available: 0, ticks_since_update: 0 }
    }
    fn is_queen(&self) -> bool {
        match self {
            Queen { .. } => true,
            _ => false
        }
    }
    fn queen_push_upcoming_hire(&mut self, to_push: Vec<SpecialistVariant>) {
        if let Queen { upcoming_hires: upcoming, .. } = self {
            *upcoming.push_back(to_push)
        }
    }
    fn queen_pop_hire(&mut self, choice: u8) -> Option<SpecialistVariant> {
        match self {
            Queen { upcoming_hires: upcoming, .. } =>
                match *upcoming.pop_front() {
                    Ok(upcoming_choices) => match upcoming_choices.get(choice) {
                        Ok(choice) => Some(choice),
                        _ => None
                    }
                    _ => None
                },
            _ => None
        }
    }
    fn queen_get_hires_available(&self) -> u16 {
        match self {
            Queen { hires_available: hires, .. } => hires.clone(),
            _ => 0
        }
    }
    fn queen_increment_hires_available(&mut self) {
        if let Queen { hires_available: hires, .. } = self {
            *hires += 1;
        }
    }
    fn queen_decrement_hires_available(&mut self) {
        if let Queen { hires_available: hires, .. } = self {
            if *hires > 0 {
                *hires -= 1;
            }
        }
    }
    fn queen_get_ticks_since(&self) -> u32 {
        match self {
            Queen { ticks_since_update: ticks, .. } => ticks.clone(),
            _ => 0
        }
    }
    fn queen_increment_ticks_since(&mut self) {
        if let Queen { ticks_since_update: ticks, .. } = self {
            *ticks += 1;
        }
    }
    fn queen_reset_ticks_since(&mut self) {
        if let Queen { ticks_since_update: ticks, .. } = self {
            *ticks = 0;
        }
    }
    fn new_princess() -> SpecialistVariant {
        Princess
    }
    fn is_princess(&self) -> bool {
        match self {
            Princess => true,
            _ => false
        }
    }
    fn new_navigator() -> SpecialistVariant {
        Navigator
    }
    fn is_navigator(&self) -> bool {
        match self {
            Navigator => true,
            _ => false
        }
    }
    fn new_pirate() -> SpecialistVariant {
        Pirate
    }
    fn is_pirate(&self) -> bool {
        match self {
            Pirate => true,
            _ => false
        }
    }
}

#[derive(Clone, Debug)]
pub enum SpecialistOwner {
    SpecPlayerOwned { player_id: String },
    SpecUnowned,
}

impl SpecialistOwner {
    pub fn new_player_owned(player: &Player) -> SpecialistOwner {
        SpecPlayerOwned { player_id: player.id.clone() }
    }
    pub fn new_unowned() -> SpecialistOwner {
        SpecUnowned
    }
    pub fn is_player_owned(&self) -> bool {
        match self {
            SpecPlayerOwned { .. } => true,
            _ => false
        }
    }
    pub fn is_unowned(&self) -> bool {
        match self {
            SpecUnowned => true,
            _ => false
        }
    }
    pub fn get_owner_id(&self) -> Option<String> {
        match self {
            SpecPlayerOwned { player_id } => Some(player_id.clone()),
            _ => None
        }
    }
    pub fn get_owning_player(&self, world: &World) -> Option<&Player> {
        match self {
            SpecPlayerOwned { player_id } => {
                world.players.iter()
                    .find(|player| player.id == player_id.to_string())
            }
            SpecUnowned => None
        }
    }
    pub fn set_player_owned(&mut self, player: &Player) {
        match self {
            SpecPlayerOwned { player_id: pid } => {
                *pid = player.id.clone()
            }
            SpecUnowned => {
                *self = SpecPlayerOwned { player_id: player.id.clone() }
            }
        }
    }
    pub fn set_unowned(&mut self) {
        match self {
            SpecUnowned => (),
            SpecPlayerOwned { .. } => {
                *self = SpecUnowned
            }
        }
    }
}

#[derive(Clone, Debug)]
pub enum SpecialistLocation {
    SpecialistOutpostLocation { outpost_id: String },
    SpecialistShipLocation { ship_id: String },
    SpecialistUnknownLocation,
}

impl SpecialistLocation {
    pub fn new_outpost_location(outpost: &Outpost) -> SpecialistLocation {
        SpecialistOutpostLocation { outpost_id: outpost.id.clone() }
    }
    pub fn new_ship_location(ship: &Ship) -> SpecialistLocation {
        SpecialistShipLocation { ship_id: ship.id.clone() }
    }
    pub fn is_outpost_location(&self) -> bool {
        match self {
            SpecialistOutpostLocation { .. } => true,
            _ => false
        }
    }
    pub fn is_ship_location(&self) -> bool {
        match self {
            SpecialistShipLocation { .. } => true,
            _ => false
        }
    }
    pub fn get_outpost_location_id(&self) -> Option<String> {
        match self {
            SpecialistOutpostLocation { outpost_id } => Some(outpost_id.clone()),
            _ => None
        }
    }
    pub fn get_ship_location_id(&self) -> Option<String> {
        match self {
            SpecialistShipLocation { ship_id } => Some(ship_id.clone()),
            _ => None
        }
    }
    pub fn get_outpost_location(&self, world: &World) -> Option<&Outpost> {
        match self {
            SpecialistOutpostLocation { outpost_id } => {
                world.outposts.iter()
                    .find(|&&outpost| outpost.id == outpost_id.to_string())
            }
            _ => None
        }
    }
    pub fn get_ship_location(&self, world: &World) -> Option<&Ship> {
        match self {
            SpecialistShipLocation { ship_id } => {
                world.ships.iter()
                    .find(|&&ship| ship.id == ship_id.to_string())
            }
            _ => None
        }
    }
    pub fn set_outpost_location(&mut self, outpost: &Outpost) {
        match self {
            SpecialistOutpostLocation { outpost_id: oid, .. } => {
                *oid = outpost.id.clone();
            }
            SpecialistShipLocation { .. } => {
                *self = SpecialistOutpostLocation { outpost_id: outpost.id.clone() }
            }
        }
    }
    pub fn set_ship_location(&mut self, ship: &Ship) {
        match self {
            SpecialistOutpostLocation { .. } => {
                *self = SpecialistShipLocation { ship_id: ship.id.clone() }
            }
            SpecialistShipLocation { ship_id: sid } => {
                *sid = ship.id.clone()
            }
        }
    }
}

#[derive(Clone, Debug)]
pub struct Specialist {
    pub id: String,
    pub variant: SpecialistVariant,
    pub owner: SpecialistOwner,
    pub location: SpecialistLocation,
}

impl Specialist {
    pub fn is_jailed(&self, world: &World) -> bool {
        match self.location {
            SpecialistOutpostLocation { .. } => {
                self.location.get_outpost_location(world)
                    .map(|&outpost| outpost.owner.get_owner_id() != self.owner.get_owner_id())
                    .unwrap_or(false)
            }
            SpecialistShipLocation { .. } => {
                self.location.get_ship_location(world)
                    .map(|&ship| ship.owner.get_owner_id() != self.owner.get_owner_id())
                    .unwrap_or(false)
            }
            _ => false
        }
    }
}
