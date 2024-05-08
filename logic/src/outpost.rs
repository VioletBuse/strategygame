use std::cell::Cell;

use crate::entity::Entity;

pub enum Owner<'a> {
    Player(Cell<&'a Entity<'a>>),
    Unowned,
}

pub enum Variant {
    Factory,
    Generator,
    Mine,
    Wreck,
    Unknown,
}

pub struct OutpostState<'a> {
    pub id: u64,
    pub owner: Owner<'a>,
    pub variant: Variant,
    pub location: (f64, f64),
    pub units: u64,
}
