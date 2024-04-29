use std::collections::HashMap;

use crate::entities::outpost::Outpost;
use crate::entities::player::Player;
use crate::entities::ship::{Ship, ShipTarget};
use crate::entities::specialist::Specialist;

#[derive(Clone, Debug)]
pub struct World {
    tick: u64,
    size: (u64, u64),
    players: HashMap<i64, Player>,
    outposts: HashMap<i64, Outpost>,
    ships: HashMap<i64, Ship>,
    specialists: HashMap<i64, Specialist>,
}

impl World {
    fn validate_location(&self, x: f64, y: f64) -> bool {
        x <= self.size.0 as f64 && y <= self.size.1 as f64
    }
    fn validate_owner(&self, owner_id: &i64) -> bool {
        self.players.contains_key(owner_id)
    }
    fn validate_players(&self) -> bool {
        self.players.iter().all(|(_, _player)| true)
    }
    fn validate_outposts(&self) -> bool {
        self.outposts.iter().all(|(_, outpost)| {
            let invalid_ownership = match outpost.owner.as_player_owned() {
                Some(player_id) => !self.validate_owner(player_id),
                None => false,
            };

            let invalid_location = matches!(
                outpost.location.as_known(),
                Some((x,y)) if self.validate_location(*x, *y)
            );

            !invalid_ownership && !invalid_location
        })
    }
    fn validate_ships(&self) -> bool {
        self.ships.iter().all(|(_, ship)| {
            let invalid_ownership = match ship.owner.as_ship_player_owned() {
                Some(player_id) => self.validate_owner(player_id),
                None => false,
            };

            let invalid_location = matches!(
                ship.location.as_known_ship_location(),
                Some((x,y)) if self.validate_location(*x, *y)
            );

            let invalid_target = match ship.target {
                ShipTarget::TargetingShip(target_ship_id) => {
                    let target_ship_exists = self.ships.contains_key(&target_ship_id);
                    let ship_has_pirate = self.specialists.iter().fold(false, |_, (_, spec)| {
                        spec.variant.is_pirate() && spec.location.as_ship() == Some(&ship.id)
                    });

                    !target_ship_exists || !ship_has_pirate
                }
                ShipTarget::TargetingOutpost(target_outpost_id) => {
                    !self.outposts.contains_key(&target_outpost_id)
                }
                ShipTarget::TargetUnknown(_) => false,
            };

            !invalid_ownership && !invalid_location && !invalid_target
        })
    }
    fn validate_specialists(&self) -> bool {
        todo!();
        self.specialists.iter().all(|(_, specialist)| true)
    }
    pub fn validate(&self) -> bool {
        if !self.validate_players() {
            return false;
        }
        if !self.validate_outposts() {
            return false;
        }
        if !self.validate_ships() {
            return false;
        }
        if !self.validate_specialists() {
            return false;
        }

        true
    }
}

#[cfg(test)]
mod test {
    use super::*;
}
