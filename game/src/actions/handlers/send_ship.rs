use crate::actions::ActionHandler;
use crate::actions::actions_list::{PlayerAction, PlayerActionEntityRef, PlayerActionVariant};
use crate::entities::world::World;

pub struct SendShipAction;

impl ActionHandler for SendShipAction {
    fn accepts_action(action: &PlayerAction) -> bool {
        action.player_action.is_send_ship()
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
                .map(|spec| match spec.as_specialist() {
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
                PlayerActionEntityRef::Outpost(outpost_id) => {
                    world.outposts.contains_key(outpost_id)
                }
                PlayerActionEntityRef::Ship(ship_id) => {
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
    fn handle(world: &mut World, action: &PlayerActionVariant) {
        todo!()
    }
}
