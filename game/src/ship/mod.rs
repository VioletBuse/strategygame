use enum_as_inner::EnumAsInner;

#[derive(Default, Debug, Clone)]
pub struct ShipData {
    id: String
}

#[derive(Debug, Clone, EnumAsInner)]
pub enum Ship {
    Ship(ShipData)
}

pub type ShipStateResult = Result<(), ShipError>;

pub enum ShipError {
    InvalidTransition
}

impl Ship {
    pub fn collect(mut self, transition: Transition) -> ShipStateResult {
        match (self, transition) {
            _ => Err(ShipError::InvalidTransition)
        }
    }
}

#[derive(Debug, Clone)]
pub enum Transition {}

