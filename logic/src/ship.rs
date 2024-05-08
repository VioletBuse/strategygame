use std::cell::Cell;

use crate::entity::Entity;

pub enum Owner<'a> {
    Player(Cell<&'a Entity<'a>>),
    Unowned,
}

pub enum Target<'a> {
    Outpost(Cell<&'a Entity<'a>>),
    Ship(Cell<&'a Entity<'a>>),
    Unknown(f64),
}

pub struct ShipState<'a> {
    pub id: u64,
    pub owner: Owner<'a>,
    pub target: Target<'a>,
    pub location: (f64, f64),
    pub units: u64,
}
