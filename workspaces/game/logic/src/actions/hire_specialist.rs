use crate::actions::PlayerAction;
use crate::entities::outpost;
use crate::entities::outpost::Outpost;
use crate::entities::specialist;
use crate::entities::specialist::Specialist;
use crate::entities::specialist::SpecialistVariant::Queen;
use crate::world::world::{World, WorldConfig};

pub fn handle(world: &mut World, config: &WorldConfig, action: &PlayerAction) {
    if let PlayerAction::HireSpecialist { player_id: pid, selection: choice } = action {
        let queen = world.specialists.iter_mut().find(|&&mut spec| {
            match spec {
                Specialist {
                    owner: specialist::SpecialistOwner::SpecPlayerOwned { player_id: spec_owner },
                    location: specialist::SpecialistLocation::SpecialistOutpostLocation { .. },
                    variant: specialist::SpecialistVariant::Queen { .. },
                    ..
                } if *spec_owner == pid.to_string() => true,
                _ => false
            }
        });

        let outpost = match queen {
            Some(queen) => {
                if let specialist::SpecialistLocation::SpecialistOutpostLocation { outpost_id: oid } = &queen.location {
                    world.outposts.iter_mut().find(|&&mut pst| {
                        match pst {
                            Outpost {
                                id: outpost_id,
                                owner: outpost::OutpostOwner::OutpostPlayerOwned { owner_id: outpost_owner },
                                ..
                            } if outpost_id == oid.to_string() && outpost_owner == pid.to_string() =>
                                true,
                            _ => false
                        }
                    })
                } else {
                    None
                }
            }
            None => None
        };

        let new_spec_variant = match queen {
            Some(Specialist{..}) => None,
            None => None
        };

        if let (
            Some(spec @ Specialist { variant: queen @ Queen { .. }, .. }),
            Some(outpost @ Outpost { .. })
        ) = (queen, outpost) {

        }
    } else {
        panic!("the hire specialist player action handler was called on an unsupported player action")
    }
}
