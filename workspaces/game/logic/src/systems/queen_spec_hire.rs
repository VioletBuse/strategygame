use crate::entities::specialist::{Variant};
use crate::entities::specialist::Variant::Queen;
use crate::world::world;
use rand::seq::SliceRandom;

pub fn handler(world: &mut world::World, config: &world::WorldConfig) {

    let ticks_per_new_hire = &config.ticks_per_hire;
    let mut hireable = config.to_owned().hireable_specs.to_owned();
    let mut rng = rand::thread_rng();

    world.specialists.iter_mut().for_each(|spec| {

        match &mut spec.variant {
            Queen {ticks_since_update: ticks, upcoming_hires: upcoming, hires_available: available} if *ticks >= *ticks_per_new_hire as u32 => {

                hireable.shuffle(&mut rng);

                let selected: Vec<Variant> = hireable.iter().take(2).clone().collect();

                *ticks = 0;
                *upcoming.push((selected));
                *available += 1;
            },
            _ => ()
        }
    })
}
