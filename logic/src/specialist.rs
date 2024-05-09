use std::cell::Cell;

use enum_as_inner::EnumAsInner;

use crate::entity::Entity;

#[derive(Clone, Debug, PartialEq, EnumAsInner)]
pub enum Location<'a> {
    Outpost(Cell<&'a Entity<'a>>),
    Ship(Cell<&'a Entity<'a>>),
    Unknown,
}

#[derive(Clone, Debug, PartialEq, EnumAsInner)]
pub enum Owner<'a> {
    Player(Cell<&'a Entity<'a>>),
    Unowned,
}

#[derive(Clone, Debug, PartialEq, EnumAsInner)]
pub enum Variant {
    Queen,
    Princess,
    Pirate,
    Navigator,
    Marksman,
}

#[derive(Clone, Debug, PartialEq)]
pub struct SpecialistState<'a> {
    pub id: u64,
    pub location: Location<'a>,
    pub owner: Owner<'a>,
    pub variant: Variant,
}
