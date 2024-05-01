use derive_new::new;
use enum_as_inner::EnumAsInner;
use thiserror::Error;

use crate::actions::actions_list::{PlayerAction, PlayerActionVariant};
use crate::entities::world;

mod actions_list;
mod handlers;

#[derive(Error, Clone, Debug, EnumAsInner, new)]
pub enum PlayerActionHandlingError {
    #[error("Error sending ship")]
    SendShipError(handlers::send_ship::SendShipError),
    #[error("Executing player doesn't exist")]
    ExecutingPlayerDoesntExist(i64),
    #[error("Action is not valid")]
    PlayerActionInvalid(PlayerAction),
    #[error("No handler registered for action of this type")]
    NoPlayerActionHandler(PlayerAction),
    #[error("Action produced an invalid world")]
    WorldValidationError(world::WorldValidationError),
}

pub trait ActionHandler {
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
                        PlayerActionHandlingError::new_executing_player_doesnt_exist(
                            action.executing_player,
                        ),
                    )?;

                    let handler = self
                        .handlers
                        .iter()
                        .find(|handler| handler.accepts_action(&action.player_action))
                        .ok_or(PlayerActionHandlingError::new_no_player_action_handler(
                            action.to_owned(),
                        ))?;

                    handler.action_is_valid(world, action).map_err(|_| {
                        PlayerActionHandlingError::new_player_action_invalid(action.to_owned())
                    })?;

                    handler.handle(world, action)?;

                    world.validate().map_err(|world_validation_err| {
                        PlayerActionHandlingError::from(world_validation_err)
                    })
                });

        execution_result
    }
}
