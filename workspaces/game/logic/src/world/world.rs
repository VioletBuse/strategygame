use crate::entities::{outpost, player, ship, specialist};

pub enum WorldVariant {

}

#[derive(Clone, Debug)]
pub struct WorldConfig {
    pub hireable_specs: Vec<specialist::Variant>,
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
    pub specialists: Vec<specialist::Specialist>
}

impl World {}
