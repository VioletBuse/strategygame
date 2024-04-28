use enum_as_inner::EnumAsInner;
use typed_builder::TypedBuilder;

#[derive(Clone, Debug, TypedBuilder)]
pub struct Specialist {
    id: i64,
    variant: SpecialistVariant,
    owner: SpecialistOwner,
    location: SpecialistLocation,
}

#[derive(Clone, Debug, EnumAsInner)]
pub enum SpecialistVariant {
    Queen,
    Princess,
    Helmsman,
    Navigator,
    Pirate,
}

#[derive(Clone, Debug, EnumAsInner)]
pub enum SpecialistOwner {
    PlayerOwned(i64),
    Unowned,
}

#[derive(Clone, Debug, EnumAsInner)]
pub enum SpecialistLocation {
    Outpost(i64),
    Ship(i64),
    Unknown,
}
