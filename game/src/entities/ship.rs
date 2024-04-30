use derive_new::new;
use enum_as_inner::EnumAsInner;
use typed_builder::TypedBuilder;

#[derive(Clone, Debug, TypedBuilder)]
pub struct Ship {
    pub id: i64,
    #[builder(setter(into))]
    pub owner: ShipOwner,
    #[builder(setter(into))]
    pub location: ShipLocation,
    #[builder(setter(into))]
    pub target: ShipTarget,
    pub units: u64,
}

#[derive(Clone, Debug, EnumAsInner, new)]
pub enum ShipOwner {
    ShipPlayerOwned(i64),
    ShipUnowned,
}

impl From<i64> for ShipOwner {
    fn from(value: i64) -> Self {
        ShipOwner::ShipPlayerOwned(value)
    }
}

impl From<Option<i64>> for ShipOwner {
    fn from(value: Option<i64>) -> Self {
        match value {
            Some(owner_id) => ShipOwner::ShipPlayerOwned(owner_id),
            None => ShipOwner::ShipUnowned,
        }
    }
}

#[derive(Clone, Debug, EnumAsInner, new)]
pub enum ShipLocation {
    KnownShipLocation(f64, f64),
    UnknownShipLocation,
}

impl From<Option<(f64, f64)>> for ShipLocation {
    fn from(value: Option<(f64, f64)>) -> Self {
        match value {
            Some((x, y)) => ShipLocation::KnownShipLocation(x, y),
            None => ShipLocation::UnknownShipLocation,
        }
    }
}

#[derive(Clone, Debug, EnumAsInner, new)]
pub enum ShipTarget {
    TargetingOutpost(i64),
    TargetingShip(i64),
    TargetUnknown(f64),
}

impl From<f64> for ShipTarget {
    fn from(value: f64) -> Self {
        ShipTarget::TargetUnknown(value)
    }
}

impl ShipTarget {}
