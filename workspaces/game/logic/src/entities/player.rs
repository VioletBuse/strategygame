use crate::entities::outpost::Outpost;
use crate::entities::ship::Ship;
use crate::entities::specialist::Specialist;
use crate::world::world::World;

#[derive(Clone, Debug)]
pub struct Player {
    pub id: String,
}

impl Player {
    pub fn get_own_outposts<'a>(&'a self, world: &'a World) -> Vec<&Outpost> {
        world.outposts.iter()
            .filter(|outpost| outpost.owner.get_owner_id() == Some(self.id.clone()))
            .collect()
    }
    pub fn get_own_specialists<'a>(&'a self, world: &'a World) -> Vec<&Specialist> {
        world.specialists.iter()
            .filter(|specialist| specialist.owner.get_owner_id() == Some(self.id.clone()))
            .collect()
    }
    pub fn get_own_ships<'a>(&'a self, world: &'a World) -> Vec<&Ship> {
        world.ships.iter()
            .filter(|ship| ship.owner.get_owner_id() == Some(self.id.clone()))
            .collect()
    }
}
