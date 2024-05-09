use std::cell::Cell;

use enum_as_inner::EnumAsInner;

use crate::entity::Entity;

#[derive(Clone, Debug, PartialEq, EnumAsInner)]
pub enum Owner<'a> {
    Player(Cell<&'a Entity<'a>>),
    Unowned,
}

#[derive(Clone, Debug, PartialEq, EnumAsInner)]
pub enum Target<'a> {
    Outpost(Cell<&'a Entity<'a>>),
    Ship(Cell<&'a Entity<'a>>),
    Unknown(f64),
}

#[derive(Clone, Debug, PartialEq)]
pub struct ShipState<'a> {
    pub id: u64,
    pub owner: Owner<'a>,
    pub target: Target<'a>,
    pub location: (f64, f64),
    pub units: u64,
}
