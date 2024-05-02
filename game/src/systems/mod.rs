use enum_as_inner::EnumAsInner;
use thiserror::Error;

use crate::entities::world;
use crate::systems::factory::system_handler_factory;

mod factory;
mod handlers;

#[derive(Error, Clone, PartialEq, Debug, EnumAsInner)]
pub enum SystemHandlingError {
    #[error("SystemHandlingError: Unable to create handlers for the following handler ids")]
    SystemExecutorConstructionError(Vec<String>),
    #[error("SystemHandlingError: System produced an invalid world")]
    WorldValidationError(world::WorldValidationError),
    #[error("SystemHandlingError: There was an error promoting princess to queen")]
    PrincessPromotionV1Error(handlers::princess_promotion::v_1::PrincessPromotionError),
    #[error("SystemHandlingError: There was an error killing queen")]
    QueenDeathV1Error(handlers::queen_death::v_1::QueenDeathError),
}

pub trait SystemHandler {
    fn handler_id(&self) -> String;
    fn handle(&self, world: &mut world::World) -> Result<(), SystemHandlingError>;
}

pub struct SystemExecutor {
    handlers: Vec<Box<dyn SystemHandler>>,
}

impl SystemExecutor {
    pub fn new(handler_ids: Vec<String>) -> Result<Self, SystemHandlingError> {
        system_handler_factory(handler_ids)
    }
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
