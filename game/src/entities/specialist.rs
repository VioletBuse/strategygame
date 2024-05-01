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

#[derive(Clone, Debug, PartialEq, EnumAsInner, new)]
pub enum SpecialistVariant {
    Queen,
    Princess,
    Helmsman,
    Navigator,
    Pirate,
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
