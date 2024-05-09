use std::cell::Cell;

use enum_as_inner::EnumAsInner;

use crate::entity::Entity;

#[derive(Clone, Debug, PartialEq, EnumAsInner)]
pub enum Owner<'a> {
    Player(Cell<&'a Entity<'a>>),
    Unowned,
}

#[derive(Clone, Debug, PartialEq, EnumAsInner)]
pub enum Variant {
    Factory,
    Generator,
    Mine,
    Wreck,
    Unknown,
}

#[derive(Clone, Debug, PartialEq)]
pub struct OutpostState<'a> {
    pub id: u64,
    pub owner: Owner<'a>,
    pub variant: Variant,
    pub location: (f64, f64),
    pub units: u64,
}
