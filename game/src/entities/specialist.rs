use std::collections::LinkedList;
use derive_new::new;
use enum_as_inner::EnumAsInner;
use typed_builder::TypedBuilder;

#[derive(Clone, Debug, PartialEq, TypedBuilder)]
pub struct Specialist {
    // pub id: i64,
    pub variant: SpecialistVariant,
    pub owner: SpecialistOwner,
    pub location: SpecialistLocation,
}

#[derive(Clone, Debug, PartialEq, TypedBuilder)]
pub struct QueenState {
    pub next_hires: LinkedList<Vec<SpecialistVariant>>,
    pub hiring_slots: u8,
    pub ticks_since_last_incr: u64,
}

#[derive(Clone, Debug, PartialEq, EnumAsInner, new)]
pub enum SpecialistVariant {
    Queen(QueenState),
    Princess,
    Helmsman,
    Navigator,
    Pirate,
}

impl SpecialistVariant {
    pub fn generate_defaults() -> Vec<SpecialistVariant> {
        vec![
            Self::new_princess(),
            Self::new_navigator(),
            Self::new_pirate()
        ]
    }
    pub fn queen_default() -> SpecialistVariant {

        let state = QueenState::builder()
            .next_hires(LinkedList::new())
            .hiring_slots(0)
            .ticks_since_last_incr(0)
            .build();

        SpecialistVariant::Queen(state)
    }
}

#[derive(Clone, Debug, PartialEq, EnumAsInner, new)]
pub enum SpecialistOwner {
    PlayerOwned(i64),
    Unowned,
}

#[derive(Clone, Debug, PartialEq, EnumAsInner, new)]
pub enum SpecialistLocation {
    Outpost(i64),
    Ship(i64),
    Unknown,
}
