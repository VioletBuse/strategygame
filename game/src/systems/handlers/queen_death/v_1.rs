use enum_as_inner::EnumAsInner;
use thiserror::Error;

use crate::entities::world::World;
use crate::systems::{SystemHandler, SystemHandlingError};

#[derive(Clone)]
pub struct Handler;

#[derive(Clone, Debug, PartialEq, EnumAsInner, Error)]
pub enum QueenDeathError {}

impl From<QueenDeathError> for SystemHandlingError {
    fn from(value: QueenDeathError) -> Self {
        Self::QueenDeathV1Error(value)
    }
}

impl QueenDeathError {
    pub fn to_system_err(self) -> SystemHandlingError {
        SystemHandlingError::QueenDeathV1Error(self)
    }
}

impl SystemHandler for Handler {
    fn handler_id(&self) -> String {
        "queen_death/v_1".to_string()
    }
    fn handle(&self, world: &mut World) -> Result<(), SystemHandlingError> {
        todo!()
    }
}
