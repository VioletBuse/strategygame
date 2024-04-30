use rand::Rng;

use crate::actions::ActionHandler;
use crate::actions::actions_list::{PlayerAction, PlayerActionEntityRef, PlayerActionVariant};
use crate::entities::ship::{Ship, ShipLocation, ShipOwner, ShipTarget};
use crate::entities::specialist::SpecialistLocation;
use crate::entities::world::World;

pub struct SendShipAction;

impl ActionHandler for SendShipAction {
    fn accepts_action(action: &PlayerActionVariant) -> bool {
        action.is_send_ship()
    }
    fn action_is_valid(world: &World, action: &PlayerAction) -> bool {
        if let PlayerAction {
            executing_player,
            player_action:
                PlayerActionVariant::SendShip {
                    from,
                    target,
                    specs,
                    units,
                },
        } = action
        {
            let player = world.players.get(executing_player);

            let executing_player_exists = player.is_some();

            let source_outpost = world.outposts.get(from);

            let outpost_exists = source_outpost.clone().is_some();
            let outpost_correct_owner = source_outpost
                .map(|outpost| outpost.owner.as_player_owned() == Some(executing_player))
                .unwrap_or(false);
            let outpost_enough_units = source_outpost
                .map(|outpost| outpost.units >= *units)
                .unwrap_or(false);

            let specialists = specs
                .iter()
                .map(|spec| match spec.as_specialist_ref() {
                    Some(spec_id) => world.specialists.get(spec_id),
                    None => None,
                })
                .fold(Some(Vec::new()), |curr, spec_opt| match (curr, spec_opt) {
                    (Some(vec), Some(spec)) => {
                        let mut new_vec = vec.clone();
                        new_vec.push(spec);

                        Some(new_vec)
                    }
                    _ => None,
                });

            let specialists_are_valid = specialists.is_some();

            let target_is_valid = match target {
                PlayerActionEntityRef::OutpostRef(outpost_id) => {
                    world.outposts.contains_key(outpost_id)
                }
                PlayerActionEntityRef::ShipRef(ship_id) => {
                    let ship_exists = world.ships.contains_key(ship_id);
                    let specs_has_pirate = specialists
                        .map(|spec_list| spec_list.iter().any(|spec| spec.variant.is_pirate()))
                        .unwrap_or(false);

                    ship_exists && specs_has_pirate
                }
                _ => false,
            };

            let valid = executing_player_exists
                && outpost_exists
                && outpost_correct_owner
                && outpost_enough_units
                && specialists_are_valid
                && target_is_valid;

            return valid;
        }

        false
    }
    fn handle(world: &mut World, action: &PlayerAction) -> anyhow::Result<()> {
        let (from, target, specs, units) = action.player_action.as_send_ship()?;

        let mut rng = rand::thread_rng();

        let new_ship_id: i64 = rng.gen();
        let new_ship_owner = ShipOwner::new_ship_player_owned(action.executing_player);
        let new_ship_target = match target {
            PlayerActionEntityRef::OutpostRef(outpost_id) => {
                Some(ShipTarget::TargetingOutpost(*outpost_id))
            }
            PlayerActionEntityRef::ShipRef(ship_id) => {
                Some(ShipTarget::new_targeting_ship(*ship_id))
            }
            _ => None,
        }?;

        let new_ship_location = world
            .outposts
            .get(&from)?
            .location
            .as_known()
            .map(|(x, y)| ShipLocation::new_known_ship_location(*x, *y))?;

        let new_spec_location = SpecialistLocation::new_ship(new_ship_id);
        let specialist_ids: Vec<i64> = specs
            .iter()
            .filter_map(|reference| reference.as_specialist_ref())
            .collect();

        let new_outpost_unit_count = world.outposts.get(&from)?.units - units;

        let new_ship = Ship::builder()
            .id(new_ship_id)
            .owner(new_ship_owner)
            .target(new_ship_target)
            .location(new_ship_location)
            .units(units)
            .build();

        world.ships.insert(new_ship_id, new_ship);
        world
            .outposts
            .entry(from)
            .and_modify(|outpost| outpost.units = new_outpost_unit_count);
        world.specialists.iter_mut().for_each(|(key, value)| {
            if specialist_ids.contains(key) {
                value.location = new_spec_location.clone();
            }
        })
    }
}
