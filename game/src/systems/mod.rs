use enum_as_inner::EnumAsInner;
use thiserror::Error;

use crate::entities::world;

mod handlers;

#[derive(Error, Clone, PartialEq, Debug, EnumAsInner)]
pub enum SystemHandlingError {
    #[error("SystemHandlingError: System produced an invalid world")]
    WorldValidationError(world::WorldValidationError),
}

pub trait SystemHandler {
    fn handler_id(&self) -> String;
    fn handle(&self, world: &mut world::World) -> Result<(), SystemHandlingError>;
}

pub struct SystemExecutor {
    handlers: Vec<Box<dyn SystemHandler>>,
}

impl SystemExecutor {
    pub fn handle_systems(&self, world: &mut world::World) -> Result<(), SystemHandlingError> {
        let system_result =
            self.handlers
                .iter()
                .try_fold((), |_, handler| -> Result<(), SystemHandlingError> {
                    handler.handle(world)?;

                    world.validate().map_err(|world_validation_err| {
                        SystemHandlingError::WorldValidationError(world_validation_err)
                    })
                });

        system_result
    }
}
