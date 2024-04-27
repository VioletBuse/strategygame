use crate::{outpost::Outpost, player::Player, ship::Ship, specialist::Spec};

pub struct World {
    pub outposts: Vec<Outpost>,
    pub players: Vec<Player>,
    pub ships: Vec<Ship>,
    pub specialists: Vec<Spec>,
}

impl World {}
