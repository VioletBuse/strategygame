use derive_new::new;
use enum_as_inner::EnumAsInner;
use rand::Rng;
use thiserror::Error;

use crate::actions::ActionHandler;
use crate::actions::actions_list::{PlayerAction, PlayerActionEntityRef, PlayerActionVariant};
use crate::actions::PlayerActionHandlingError;
use crate::entities::ship::{Ship, ShipLocation, ShipOwner, ShipTarget};
use crate::entities::specialist::{Specialist, SpecialistLocation};
use crate::entities::world::World;

pub struct SendShipAction;

#[derive(Error, Clone, Debug, EnumAsInner, new)]
pub enum SendShipError {
    #[error("SendShipAction: Could not send ship because player executing action does not exist")]
    ExecutingPlayerDoesNotExist,
    #[error("SendShipAction: Source outpost does not exist")]
    SourceOutpostDoesNotExist,
    #[error("SendShipAction: Source outpost location is not known")]
    SourceOutpostLocationUnknown,
    #[error("SendShipAction: Source outpost is not owned by executing player")]
    SourceOutpostInvalidOwnership,
    #[error("SendShipAction: Source outpost does not have enough units")]
    NotEnoughUnitsAtSourceOutpost,
    #[error("SendShipAction: Cannot target outpost that doesn't exist")]
    TargetOutpostDoesntExist,
    #[error("SendShipAction: Cannot target ship that doesn't exist")]
    TargetShipDoesntExist,
    #[error("SendShipAction: Cannot target ship if there isn't a pirate among the specialists")]
    CannotTargetShipWithoutPirate,
    #[error("SendShipAction: Otherwise invalid target")]
    OtherwiseInvalidTarget,
    #[error("SendShipAction: Not all specified specialists exist")]
    InvalidSpecialistList,
    #[error("Invalid action for send_ship")]
    InvalidSendShipAction,
}

impl From<SendShipError> for PlayerActionHandlingError {
    fn from(value: SendShipError) -> Self {
        Self::SendShipError(value)
    }
}
impl ActionHandler for SendShipAction {
    fn accepts_action(&self, action: &PlayerActionVariant) -> bool {
        action.is_send_ship()
    }
    fn action_is_valid(
        &self,
        world: &World,
        action: &PlayerAction,
    ) -> Result<(), PlayerActionHandlingError> {
        let PlayerAction {
            executing_player,
            player_action,
        } = action;

        if let PlayerActionVariant::SendShip {
            from,
            target,
            specs,
            units,
        } = player_action
        {
            world
                .players
                .get(executing_player)
                .ok_or(SendShipError::ExecutingPlayerDoesNotExist)?;

            let source_outpost = world
                .outposts
                .get(from)
                .ok_or(SendShipError::SourceOutpostDoesNotExist)?;

            source_outpost
                .owner
                .as_player_owned()
                .ok_or(SendShipError::SourceOutpostInvalidOwnership)
                .and_then(|outpost_owner| match outpost_owner == executing_player {
                    true => Ok(()),
                    false => Err(SendShipError::SourceOutpostInvalidOwnership),
                })?;

            if source_outpost.units < *units {
                return Err(PlayerActionHandlingError::from(
                    SendShipError::NotEnoughUnitsAtSourceOutpost,
                ));
            }

            let specialists: Vec<&Specialist> = specs
                .iter()
                .map(|spec| -> Option<&Specialist> {
                    let spec_id = spec.as_specialist()?;
                    world.specialists.get(spec_id)
                })
                .collect::<Option<Vec<&Specialist>>>()
                .ok_or(SendShipError::InvalidSpecialistList)?;

            match target {
                PlayerActionEntityRef::Outpost(outpost_id) => {
                    if !world.outposts.contains_key(outpost_id) {
                        return Err(PlayerActionHandlingError::from(
                            SendShipError::TargetOutpostDoesntExist,
                        ));
                    }
                }
                PlayerActionEntityRef::Ship(ship_id) => {
                    if !world.ships.contains_key(ship_id) {
                        return Err(PlayerActionHandlingError::from(
                            SendShipError::TargetShipDoesntExist,
                        ));
                    }

                    let includes_pirate = specialists
                        .clone()
                        .iter_mut()
                        .any(|spec| spec.variant.is_pirate());

                    if !includes_pirate {
                        return Err(PlayerActionHandlingError::from(
                            SendShipError::CannotTargetShipWithoutPirate,
                        ));
                    }
                }
                _ => {
                    return Err(PlayerActionHandlingError::from(
                        SendShipError::InvalidSendShipAction,
                    ))
                }
            }

            return Ok(());
        }

        Err(PlayerActionHandlingError::from(
            SendShipError::InvalidSendShipAction,
        ))
    }
    fn handle(
        &self,
        world: &mut World,
        action: &PlayerAction,
    ) -> Result<(), PlayerActionHandlingError> {
        SendShipAction {}.action_is_valid(world, action)?;

        let (from, target, specs, units) = action
            .player_action
            .as_send_ship()
            .ok_or(SendShipError::InvalidSendShipAction)?;

        let mut rng = rand::thread_rng();

        let new_ship_id: i64 = rng.gen();
        let new_ship_owner = ShipOwner::new_ship_player_owned(action.executing_player);
        let new_ship_target = match target {
            PlayerActionEntityRef::Outpost(outpost_id) => {
                Some(ShipTarget::TargetingOutpost(*outpost_id))
            }
            PlayerActionEntityRef::Ship(ship_id) => Some(ShipTarget::new_targeting_ship(*ship_id)),
            _ => None,
        }
        .ok_or(SendShipError::OtherwiseInvalidTarget)?;

        let new_ship_location = world
            .outposts
            .get(from)
            .ok_or(SendShipError::SourceOutpostDoesNotExist)?
            .location
            .as_known()
            .map(|(x, y)| ShipLocation::new_known_ship_location(*x, *y))
            .ok_or(SendShipError::SourceOutpostLocationUnknown)?;

        let new_spec_location = SpecialistLocation::new_ship(new_ship_id);
        let specialist_ids: Vec<&i64> = specs
            .iter()
            .map(|spec| spec.as_specialist())
            .collect::<Option<Vec<&i64>>>()
            .ok_or(SendShipError::InvalidSpecialistList)?;

        let new_outpost_unit_count = world
            .outposts
            .get(from)
            .ok_or(SendShipError::NotEnoughUnitsAtSourceOutpost)?
            .units
            - units;

        let new_ship = Ship::builder()
            .owner(new_ship_owner)
            .target(new_ship_target)
            .location(new_ship_location)
            .units(*units)
            .build();

        world.ships.insert(new_ship_id, new_ship);
        world
            .outposts
            .entry(*from)
            .and_modify(|outpost| outpost.units = new_outpost_unit_count);
        world.specialists.iter_mut().for_each(|(key, value)| {
            if specialist_ids.contains(&key) {
                value.location = new_spec_location.clone();
            }
        });

        Ok(())
    }
}

#[cfg(test)]
mod test {
    use std::collections::HashMap;

    use pretty_assertions::assert_eq;

    use crate::actions;
    use crate::entities::{outpost, player, world};

    use super::*;

    #[test]
    fn basic_send_ship() {
        let player_1 = player::Player::builder().build();

        let source_outpost = outpost::Outpost::builder()
            .variant(outpost::OutpostVariant::new_generator())
            .owner(outpost::OutpostOwner::new_player_owned(0))
            .units(5)
            .location(outpost::OutpostLocation::new_known(0., 0.))
            .build();

        let target_outpost = outpost::Outpost::builder()
            .variant(outpost::OutpostVariant::new_generator())
            .owner(outpost::OutpostOwner::new_player_owned(0))
            .units(0)
            .location(outpost::OutpostLocation::new_known(2., 2.))
            .build();

        let mut player_map: HashMap<i64, player::Player> = HashMap::new();
        let mut outpost_map: HashMap<i64, outpost::Outpost> = HashMap::new();

        player_map.insert(0, player_1);

        outpost_map.insert(0, source_outpost);
        outpost_map.insert(1, target_outpost);

        let mut new_world = world::World {
            tick: 0,
            size: (5, 5),
            players: player_map,
            outposts: outpost_map,
            ships: HashMap::new(),
            specialists: HashMap::new(),
        };

        let action = actions::PlayerAction {
            executing_player: 0,
            player_action: PlayerActionVariant::SendShip {
                from: 0,
                target: PlayerActionEntityRef::Outpost(0),
                specs: vec![],
                units: 4,
            },
        };

        let result = SendShipAction {}.handle(&mut new_world, &action);

        assert_eq!(result.is_ok(), true, "This should not return an error");

        // assert_eq!(new_world.players.get(&0), None);

        let world_valid = new_world.validate();

        assert_eq!(
            world_valid,
            Ok(()),
            "This action handler should not return an invalid world"
        );

        let mut keys = new_world.ships.keys();

        assert_eq!(keys.len(), 1, "There should be one ship");

        let ship_id = keys.find(|_| true).unwrap();

        let ship = new_world.ships.get(ship_id).unwrap();

        assert_eq!(ship.units, 4, "Ship should have 4 units");

        let source = new_world.outposts.get(&0_i64).unwrap();

        assert_eq!(source.units, 1, "Source outpost should have 1 unit")
    }
}
