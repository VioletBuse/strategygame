use enum_as_inner::EnumAsInner;
use thiserror::Error;
use crate::entities::world::World;
use crate::systems::{SystemHandler, SystemHandlingError};

#[derive(Clone)]
pub struct Handler;

#[derive(Clone, Debug, PartialEq, Error, EnumAsInner)]
pub enum SpecialistCleanupError {

}

impl From<SpecialistCleanupError> for SystemHandlingError {
    fn from(value: SpecialistCleanupError) -> Self {
        Self::DeadSpecialistCleanupV1Error(value)
    }
}

impl SpecialistCleanupError {
    pub fn to_system_error(self) -> SystemHandlingError {
        SystemHandlingError::DeadSpecialistCleanupV1Error(self)
    }
}

impl SystemHandler for Handler {
    fn handler_id(&self) -> String {
        "dead_specialist_cleanup/v_1".to_string()
    }
    fn handle(&self, world: &mut World) -> Result<(), SystemHandlingError> {
        world.dead_specialists.clear();

        Ok(())
    }
}
