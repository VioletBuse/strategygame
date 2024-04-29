use derive_new::new;
use enum_as_inner::EnumAsInner;
use typed_builder::TypedBuilder;

#[derive(Clone, Debug, TypedBuilder)]
pub struct Outpost {
    pub id: i64,
    #[builder(setter(into))]
    pub variant: OutpostVariant,
    #[builder(setter(into))]
    pub owner: OutpostOwner,
    #[builder(setter(into))]
    pub location: OutpostLocation,
    units: u64,
}

#[derive(Clone, Debug, EnumAsInner, new)]
pub enum OutpostVariant {
    Factory,
    Generator,
    Mine,
    Ruin,
    Unknown,
}

#[derive(Clone, Debug, EnumAsInner, new)]
pub enum OutpostOwner {
    PlayerOwned(i64),
    Unowned,
}

impl From<Option<i64>> for OutpostOwner {
    fn from(value: Option<i64>) -> Self {
        match value {
            Some(owner_id) => OutpostOwner::PlayerOwned(owner_id),
            None => OutpostOwner::Unowned,
        }
    }
}

#[derive(Clone, Debug, EnumAsInner, new)]
pub enum OutpostLocation {
    Known(f64, f64),
}

impl From<(f64, f64)> for OutpostLocation {
    fn from(value: (f64, f64)) -> Self {
        OutpostLocation::Known(value.0, value.1)
    }
}
