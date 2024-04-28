use enum_as_inner::EnumAsInner;

#[derive(Clone, Debug, PartialEq, PartialOrd, EnumAsInner)]
pub enum OutpostLocation {
    KnownOutpostLocation(f64, f64),
}

impl From<(f64, f64)> for OutpostLocation {
    fn from(value: (f64, f64)) -> Self {
        OutpostLocation::KnownOutpostLocation(value.0, value.1)
    }
}

impl From<(i64, i64)> for OutpostLocation {
    fn from(value: (i64, i64)) -> Self {
        OutpostLocation::KnownOutpostLocation(value.0 as f64, value.1 as f64)
    }
}

impl OutpostLocation {
    pub fn new(x: f64, y: f64) -> OutpostLocation {
        OutpostLocation::KnownOutpostLocation(x, y)
    }
    pub fn get_coords(&self) -> Option<(f64, f64)> {
        match self {
            OutpostLocation::KnownOutpostLocation(x, y) => Some((x.clone(), y.clone()))
        }
    }
}
