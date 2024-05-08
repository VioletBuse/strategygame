use crate::outpost::OutpostState;
use crate::player::PlayerState;
use crate::ship::ShipState;
use crate::specialist::SpecialistState;

pub enum Entity<'a> {
    Player(PlayerState<'a>),
    Outpost(OutpostState<'a>),
    Ship(ShipState<'a>),
    Specialist(SpecialistState<'a>),
}
