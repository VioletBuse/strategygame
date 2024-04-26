use crate::world::world;
use rand::seq::SliceRandom;

pub fn handler(world: &mut world::World, config: &world::WorldConfig) {
    let mut hireable = config.to_owned().hireable_specs.to_owned();
    let mut rng = rand::thread_rng();

    world.specialists.iter_mut().for_each(|spec| {
        if spec.variant.is_queen() {
            let mut shuffled = hireable.clone();
            shuffled.shuffle(&mut rng);

            let selected = shuffled.iter()
                .take(config.choices_per_hire as usize)
                .map(|variant| variant.clone())
                .collect();

            spec.variant.queen_reset_ticks_since();
            spec.variant.queen_push_upcoming_hire(selected);
            spec.variant.queen_increment_hires_available();
        }
    })
}
