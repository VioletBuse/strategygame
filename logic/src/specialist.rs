use std::cell::Cell;

use crate::entity::Entity;

pub enum Location<'a> {
    Outpost(Cell<&'a Entity<'a>>),
    Ship(Cell<&'a Entity<'a>>),
    Unknown,
}

pub enum Owner<'a> {
    Player(Cell<&'a Entity<'a>>),
    Unowned,
}

pub enum Variant {
    Queen,
    Princess,
    Pirate,
    Navigator,
    Marksman,
}

pub struct SpecialistState<'a> {
    pub id: u64,
    pub location: Location<'a>,
    pub owner: Owner<'a>,
    pub variant: Variant,
}
