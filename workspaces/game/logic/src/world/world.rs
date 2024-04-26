use crate::entities::{outpost, player, ship, specialist};
use crate::entities::specialist::Specialist;

pub enum WorldVariant {}

#[derive(Clone, Debug)]
pub struct WorldConfig {
    pub choices_per_hire: u8,
    pub hireable_specs: Vec<specialist::SpecialistVariant>,
    pub ticks_per_hire: u16,
}

#[derive(Clone, Debug)]
pub struct World {
    pub current_tick: u32,
    pub width: u32,
    pub height: u32,
    pub outposts: Vec<outpost::Outpost>,
    pub ships: Vec<ship::Ship>,
    pub players: Vec<player::Player>,
    pub specialists: Vec<Specialist>,
}

impl World {
    pub fn add_specialist(&mut self, specialist: Specialist) {
        self.specialists.push(specialist)
    }
}
