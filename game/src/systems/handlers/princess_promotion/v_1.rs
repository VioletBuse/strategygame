use enum_as_inner::EnumAsInner;
use thiserror::Error;

use crate::entities::world::World;
use crate::systems::{SystemHandler, SystemHandlingError};

#[derive(Clone)]
pub struct Handler;

#[derive(Clone, Debug, PartialEq, Error, EnumAsInner)]
pub enum PrincessPromotionError {
    #[error("PrincessPromotionError: Invalid data found")]
    InvalidDataFound,
}

impl From<PrincessPromotionError> for SystemHandlingError {
    fn from(value: PrincessPromotionError) -> Self {
        Self::PrincessPromotionV1Error(value)
    }
}

impl PrincessPromotionError {
    pub fn to_system_err(self) -> SystemHandlingError {
        SystemHandlingError::PrincessPromotionV1Error(self)
    }
}

impl SystemHandler for Handler {
    fn handler_id(&self) -> String {
        "princess_promotion/v1".to_string()
    }
    fn handle(&self, world: &mut World) -> Result<(), SystemHandlingError> {
        let eligible_entries = world
            .players
            .iter()
            .filter_map(|(player_id, _)| {
                let queen = world.dead_specialists.iter().find(|(_, spec)| {
                    spec.owner
                        .as_player_owned()
                        .map_or(false, |owner_id| owner_id == player_id)
                        && spec.variant.is_queen()
                });
                let princess = world.specialists.iter().find(|(_, spec)| {
                    spec.owner.as_player_owned().map_or(false, |owner_id| {
                        owner_id == player_id && spec.variant.is_princess()
                    })
                });

                match (queen, princess) {
                    (Some((queen_id, _)), Some((princess_id, _))) => Some((
                        player_id.to_owned(),
                        queen_id.to_owned(),
                        princess_id.to_owned(),
                    )),
                    _ => None,
                }
            })
            .collect::<Vec<(i64, i64, i64)>>();

        let princess_ids = eligible_entries
            .iter()
            .map(|(_, _, id)| id.to_owned())
            .collect::<Vec<i64>>();

        world
            .specialists
            .iter_mut()
            .filter(|(spec_id, _)| princess_ids.contains(spec_id))
            .for_each(|(princess_id, princess)| {
                let entry = eligible_entries
                    .iter()
                    .find(|(_, _, entry_princess_id)| princess_id == entry_princess_id)
                    .ok_or(PrincessPromotionError::InvalidDataFound);

                if let Ok((_, queen_id, _)) = entry {
                    let queen_variant = world
                        .dead_specialists
                        .get(queen_id)
                        .ok_or(PrincessPromotionError::InvalidDataFound)
                        .clone()
                        .map(|p| p.variant.clone());

                    if let Ok(queen_variant) = queen_variant {
                        princess.variant = queen_variant;
                    }
                };
            });

        Ok(())
    }
}
