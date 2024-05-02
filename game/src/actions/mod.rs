use enum_as_inner::EnumAsInner;
use thiserror::Error;

use crate::actions::actions_list::{PlayerAction, PlayerActionVariant};
use crate::actions::factory::action_handler_factory;
use crate::entities::world;

mod actions_list;
mod factory;
mod handlers;

#[derive(Error, Clone, PartialEq, Debug, EnumAsInner)]
pub enum PlayerActionHandlingError {
    #[error("PlayerActionHandlingError: Unable to construct handlers for the following ids")]
    ActionExecutorConstructionError(Vec<String>),
    #[error("PlayerActionHandlingError: Error sending ship")]
    SendShipV1Error(handlers::send_ship::v_1::SendShipError),
    #[error("PlayerActionHandlingError: Executing player doesn't exist")]
    ExecutingPlayerDoesntExist(i64),
    #[error("PlayerActionHandlingError: Action is not valid")]
    PlayerActionInvalid(PlayerAction),
    #[error("PlayerActionHandlingError: No handler registered for action of this type")]
    NoPlayerActionHandler(PlayerAction),
    #[error("PlayerActionHandlingError: Action produced an invalid world")]
    WorldValidationError(world::WorldValidationError),
}

pub trait ActionHandler {
    fn handler_id(&self) -> String;
    fn accepts_action(&self, action: &PlayerActionVariant) -> bool;
    fn action_is_valid(
        &self,
        world: &world::World,
        action: &PlayerAction,
    ) -> Result<(), PlayerActionHandlingError>;
    fn handle(
        &self,
        world: &mut world::World,
        action: &PlayerAction,
    ) -> Result<(), PlayerActionHandlingError>;
}

pub struct ActionsExecutor {
    handlers: Vec<Box<dyn ActionHandler>>,
}

impl ActionsExecutor {
    pub fn new(handlers: Vec<String>) -> Result<Self, PlayerActionHandlingError> {
        action_handler_factory(handlers)
    }
    pub fn handle_actions(
        &self,
        world: &mut world::World,
        actions: &[PlayerAction],
    ) -> Result<(), PlayerActionHandlingError> {
        let execution_result =
            actions
                .iter()
                .try_fold((), |_, action| -> Result<(), PlayerActionHandlingError> {
                    world.players.get(&action.executing_player).ok_or(
                        PlayerActionHandlingError::ExecutingPlayerDoesntExist(
                            action.executing_player,
                        ),
                    )?;

                    let handler = self
                        .handlers
                        .iter()
                        .find(|handler| handler.accepts_action(&action.player_action))
                        .ok_or(PlayerActionHandlingError::NoPlayerActionHandler(
                            action.to_owned(),
                        ))?;

                    handler.action_is_valid(world, action).map_err(|_| {
                        PlayerActionHandlingError::PlayerActionInvalid(action.to_owned())
                    })?;

                    handler.handle(world, action)?;

                    world.validate().map_err(|world_validation_err| {
                        PlayerActionHandlingError::from(world_validation_err)
                    })
                });

        execution_result
    }
}
