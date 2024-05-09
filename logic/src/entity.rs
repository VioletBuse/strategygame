use enum_as_inner::EnumAsInner;

use crate::outpost::OutpostState;
use crate::player::PlayerState;
use crate::ship::ShipState;
use crate::specialist::SpecialistState;

#[derive(Clone, Debug, PartialEq, EnumAsInner)]
pub enum Entity<'a> {
    Player(PlayerState),
    Outpost(OutpostState<'a>),
    Ship(ShipState<'a>),
    Specialist(SpecialistState<'a>),
}
