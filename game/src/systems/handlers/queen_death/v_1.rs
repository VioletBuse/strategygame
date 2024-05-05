use enum_as_inner::EnumAsInner;
use thiserror::Error;
use crate::entities::specialist;

use crate::entities::world::World;
use crate::systems::{SystemHandler, SystemHandlingError};

#[derive(Clone)]
pub struct Handler;

#[derive(Clone, Debug, PartialEq, EnumAsInner, Error)]
pub enum QueenDeathError {}

impl From<QueenDeathError> for SystemHandlingError {
    fn from(value: QueenDeathError) -> Self {
        Self::QueenDeathV1Error(value)
    }
}

impl QueenDeathError {
    pub fn to_system_err(self) -> SystemHandlingError {
        SystemHandlingError::QueenDeathV1Error(self)
    }
}

impl SystemHandler for Handler {
    fn handler_id(&self) -> String {
        "queen_death/v_1".to_string()
    }
    fn handle(&self, world: &mut World) -> Result<(), SystemHandlingError> {

        let keys = world.specialists.keys();

        for id in keys {
            let value = world.specialists.get(id);

            let spec = match value {
                Some(spec) => spec,
                None => continue
            };

            let specialist::SpecialistOwner::PlayerOwned(owner_id) = spec.owner else {
                continue;
            };

            if !spec.variant.is_queen() {
                continue;
            }

            let owns_location = match spec.location {
                specialist::SpecialistLocation::Outpost(outpost_id) => {
                    let outpost = world.outposts.get(*outpost_id);
                    let outpost_owned_player = outpost.map(|outpost| outpost.owner.as_player_owned()).flatten();
                    outpost_owned_player.map(|outpost_owner_id| *outpost_owner_id == owner_id).unwrap_or(false)
                },
                specialist::SpecialistLocation::Ship(ship_id) => {
                    let ship = world.ships.get(*ship_id);
                    let ship_owned_player = ship.map(|ship| ship.owner.as_ship_player_owned()).flatten();
                    ship_owned_player.map(|ship_owner_id| *ship_owner_id == owner_id).unwrap_or(false)
                },
                specialist::SpecialistLocation::Unknown => continue
            };

            if owns_location {
                continue;
            }

            let specialist_id = id.to_owned();
            let specialist = world.specialists.remove(*specialist_id).unwrap();
            world.dead_specialists.insert(specialist_id, specialist);
        }


        Ok(())
    }
}
