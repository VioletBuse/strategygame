use derive_new::new;
use enum_as_inner::EnumAsInner;
use thiserror::Error;

use crate::actions::actions_list::{PlayerAction, PlayerActionVariant};
use crate::entities::world::World;

mod actions_list;
mod handlers;

#[derive(Error, Clone, Debug, EnumAsInner, new)]
pub enum PlayerActionHandlingError {
    #[error("Error sending ship")]
    SendShipError(handlers::send_ship::SendShipError),
    #[error("Executing player doesn't exist")]
    ExecutingPlayerDoesntExist(i64),
    #[error("Action is not valid")]
    PlayerActionInvalid,
}

pub trait ActionError {
    fn generalize(self) -> PlayerActionHandlingError;
}

pub trait ActionHandler {
    fn accepts_action(action: &PlayerActionVariant) -> bool;
    fn action_is_valid(
        world: &World,
        action: &PlayerAction,
    ) -> Result<(), PlayerActionHandlingError>;
    fn handle(world: &mut World, action: &PlayerAction) -> Result<(), PlayerActionHandlingError>;
}
