use enum_as_inner::EnumAsInner;
use typed_builder::TypedBuilder;

#[derive(Clone, Debug, TypedBuilder)]
pub struct Ship {
    id: i64,
    #[builder(setter(into))]
    owner: ShipOwner,
    #[builder(setter(into))]
    location: ShipLocation,
    #[builder(setter(into))]
    target: ShipTarget,
    units: u32,
}

#[derive(Clone, Debug, EnumAsInner)]
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

#[derive(Clone, Debug, EnumAsInner)]
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

#[derive(Clone, Debug, EnumAsInner)]
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

impl ShipTarget {
    pub fn new_targeting_outpost(outpost_id: i64) -> ShipTarget {
        ShipTarget::TargetingOutpost(outpost_id)
    }
    pub fn new_targeting_ship(ship_id: i64) -> ShipTarget {
        ShipTarget::TargetingShip(ship_id)
    }
    pub fn new_targeting_unknown(heading: f64) -> ShipTarget {
        ShipTarget::TargetUnknown(heading)
    }
}
