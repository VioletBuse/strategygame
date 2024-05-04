use std::collections::HashMap;

use derive_new::new;
use enum_as_inner::EnumAsInner;
use thiserror::Error;

use crate::actions::PlayerActionHandlingError;
use crate::entities::{outpost, player, ship, specialist};

#[derive(Clone, Debug, PartialEq)]
pub struct World {
    pub tick: u64,
    pub size: (u64, u64),
    pub config: WorldConfig,
    pub players: HashMap<i64, player::Player>,
    pub outposts: HashMap<i64, outpost::Outpost>,
    pub ships: HashMap<i64, ship::Ship>,
    pub specialists: HashMap<i64, specialist::Specialist>,
    pub dead_specialists: HashMap<i64, specialist::Specialist>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct WorldConfig {
    pub target_ship_pirate_required: bool,

    // queen config
    pub ticks_till_next_specialist_hire_incr: u32,
    pub specialist_hire_choice_count: u8
}

impl Default for WorldConfig {
    fn default() -> Self {
        Self {
            target_ship_pirate_required: true,
            specialist_hire_choice_count: 3,
            ticks_till_next_specialist_hire_incr: 5_184
        }
    }
}

#[derive(Clone, Debug, PartialEq, Error, EnumAsInner, new)]
pub enum WorldValidationError {
    #[error("WorldValidationError: Outpost owner does not exist")]
    OutpostOwnerNotExist(i64, i64),
    #[error("WorldValidationError: Outpost exists outside of bounds of the world")]
    OutpostLocationOutOfBounds(i64, f64, f64),
    #[error("WorldValidationError: Ship owner does not exist")]
    ShipOwnerNotExist(i64, i64),
    #[error("WorldValidationError: Ship exists outside of bounds of the world")]
    ShipLocationOutOfBounds(i64, f64, f64),
    #[error("WorldValidationError: Ship target outpost does not exist")]
    ShipTargetOutpostNotExist(i64, i64),
    #[error("WorldValidationError: Ship target ship does not exist")]
    ShipTargetShipNotExist(i64, i64),
    #[error("WorldValidationError: Ship cannot target another ship without a pirate onboard")]
    ShipCannotTargetShipWithoutPirate(i64),
    #[error("WorldValidationError: Ships may not carry more than three specialists")]
    ShipTooManySpecs(i64, usize),
    #[error("WorldValidationError: Ship headings cannot be greater than 360 deg")]
    ShipTargetHeadingOOB(i64),
    #[error("WorldValidationError: Specialist owner does not exist")]
    SpecialistOwnerNotExist(i64, i64),
    #[error("WorldValidationError: Specialist outpost location does not exist")]
    SpecialistOutpostLocationNotExist(i64, i64),
    #[error("WorldValidationError: Specialist ship location does not exist")]
    SpecialistShipLocationNotExist(i64, i64),
}

impl From<WorldValidationError> for PlayerActionHandlingError {
    fn from(value: WorldValidationError) -> Self {
        Self::WorldValidationError(value)
    }
}

impl World {
    fn validate_players(&self) -> Result<(), WorldValidationError> {
        Ok(())
    }
    fn validate_outposts(&self) -> Result<(), WorldValidationError> {
        self.outposts
            .iter()
            .map(
                |(outpost_id, outpost)| -> Result<(), WorldValidationError> {
                    // validate outpost ownership
                    match outpost.owner {
                        outpost::OutpostOwner::PlayerOwned(owner_id) => {
                            self.players.get(&owner_id).ok_or(
                                WorldValidationError::new_outpost_owner_not_exist(
                                    outpost_id.to_owned(),
                                    owner_id,
                                ),
                            )?;
                        }
                        outpost::OutpostOwner::Unowned => {}
                    }

                    // validate outpost location
                    match outpost.location {
                        outpost::OutpostLocation::Known(x, y) => {
                            if x > self.size.0 as f64 || y > self.size.1 as f64 {
                                return Err(WorldValidationError::OutpostLocationOutOfBounds(
                                    outpost_id.to_owned(),
                                    x,
                                    y,
                                ));
                            }
                        }
                    }

                    Ok(())
                },
            )
            .collect::<Result<Vec<()>, WorldValidationError>>()
            .map(|_| ())
    }
    fn validate_ships(&self) -> Result<(), WorldValidationError> {
        self.ships
            .iter()
            .map(|(ship_id, ship)| -> Result<(), WorldValidationError> {
                // validate ship ownership
                match ship.owner {
                    ship::ShipOwner::ShipPlayerOwned(owner_id) => {
                        self.players.get(&owner_id).ok_or(
                            WorldValidationError::new_ship_owner_not_exist(
                                ship_id.to_owned(),
                                owner_id,
                            ),
                        )?;
                    }
                    ship::ShipOwner::ShipUnowned => {}
                }

                // validate ship location
                match ship.location {
                    ship::ShipLocation::KnownShipLocation(x, y) => {
                        if x > self.size.0 as f64 || y > self.size.1 as f64 {
                            return Err(WorldValidationError::new_ship_location_out_of_bounds(
                                ship_id.to_owned(),
                                x,
                                y,
                            ));
                        }
                    }
                    ship::ShipLocation::UnknownShipLocation => {}
                }

                // validate ship target
                match ship.target {
                    ship::ShipTarget::TargetingOutpost(target_outpost_id) => {
                        self.outposts.get(&target_outpost_id).ok_or(
                            WorldValidationError::new_ship_target_outpost_not_exist(
                                ship_id.to_owned(),
                                target_outpost_id,
                            ),
                        )?;
                    }
                    ship::ShipTarget::TargetingShip(target_ship_id) => {
                        // targeting ship exists
                        self.ships.get(&target_ship_id).ok_or(
                            WorldValidationError::new_ship_target_ship_not_exist(
                                ship_id.to_owned(),
                                target_ship_id,
                            ),
                        )?;

                        // ship has a pirate
                        self.specialists
                            .iter()
                            .find(|(_, spec)| {
                                let located_on_ship = spec
                                    .location
                                    .as_ship()
                                    .map(|location_id| location_id == ship_id)
                                    .unwrap_or(false);
                                let is_pirate = spec.variant.is_pirate();

                                located_on_ship && is_pirate
                            })
                            .ok_or(
                                WorldValidationError::new_ship_cannot_target_ship_without_pirate(
                                    ship_id.to_owned(),
                                ),
                            )?;
                    }
                    ship::ShipTarget::TargetUnknown(heading) => {
                        if heading > 360. {
                            return Err(WorldValidationError::new_ship_target_heading_oob(
                                ship_id.to_owned(),
                            ));
                        }
                    }
                }

                // validate ship spec count
                let spec_count = self
                    .specialists
                    .iter()
                    .filter(|(_, spec)| {
                        spec.location
                            .as_ship()
                            .map(|location_id| location_id == ship_id)
                            .unwrap_or(false)
                    })
                    .count();
                if spec_count > 3 {
                    return Err(WorldValidationError::ShipTooManySpecs(
                        ship_id.to_owned(),
                        spec_count,
                    ));
                }

                Ok(())
            })
            .collect::<Result<Vec<()>, WorldValidationError>>()
            .map(|_| ())
    }
    fn validate_specialists(&self) -> Result<(), WorldValidationError> {
        self.specialists
            .iter()
            .map(|(spec_id, spec)| -> Result<(), WorldValidationError> {
                // validate valid ownership
                match spec.owner {
                    specialist::SpecialistOwner::PlayerOwned(owner_id) => {
                        self.players.get(&owner_id).ok_or(
                            WorldValidationError::new_specialist_owner_not_exist(
                                spec_id.to_owned(),
                                owner_id,
                            ),
                        )?;
                    }
                    specialist::SpecialistOwner::Unowned => {}
                }

                match spec.location {
                    specialist::SpecialistLocation::Outpost(outpost_id) => {
                        self.outposts.get(&outpost_id).ok_or(
                            WorldValidationError::new_specialist_outpost_location_not_exist(
                                spec_id.to_owned(),
                                outpost_id,
                            ),
                        )?;
                    }
                    specialist::SpecialistLocation::Ship(ship_id) => {
                        self.ships.get(&ship_id).ok_or(
                            WorldValidationError::new_specialist_ship_location_not_exist(
                                spec_id.to_owned(),
                                ship_id,
                            ),
                        )?;
                    }
                    specialist::SpecialistLocation::Unknown => {}
                }

                Ok(())
            })
            .collect::<Result<Vec<()>, WorldValidationError>>()
            .map(|_| ())
    }
    pub fn validate(&self) -> Result<(), WorldValidationError> {
        self.validate_players()?;
        self.validate_outposts()?;
        self.validate_ships()?;
        self.validate_specialists()?;

        Ok(())
    }
}
