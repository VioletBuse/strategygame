use enum_as_inner::EnumAsInner;
use thiserror::Error;
use crate::entities::world::World;
use crate::systems::{SystemHandler, SystemHandlingError};

#[derive(Clone)]
pub struct Handler;

#[derive(Clone, Debug, PartialEq, EnumAsInner, Error)]
pub enum QueenHiringOptionsGenError {

}

impl From<QueenHiringOptionsGenError> for SystemHandlingError {
    fn from(value: QueenHiringOptionsGenError) -> Self {
        Self::QueenHiringOptionsGenV1Error(value)
    }
}

impl QueenHiringOptionsGenError {
    pub fn to_system_error(self) -> SystemHandlingError {
        SystemHandlingError::QueenHiringOptionsGenV1Error(self)
    }
}

impl SystemHandler for Handler {
    fn handler_id(&self) -> String {
        "queen_hiring_options/v_1".to_string()
    }
    fn handle(&self, world: &mut World) -> Result<(), SystemHandlingError> {
        todo!()
    }
}
