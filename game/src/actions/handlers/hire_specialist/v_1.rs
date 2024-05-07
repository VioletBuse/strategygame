use enum_as_inner::EnumAsInner;
use thiserror::Error;

use crate::actions::{ActionHandler, PlayerActionHandlingError};
use crate::actions::actions_list::{PlayerAction, PlayerActionVariant};
use crate::entities::world::World;

#[derive(Clone)]
pub struct Handler;

#[derive(Error, Clone, Debug, PartialEq, EnumAsInner)]
pub enum HireSpecialistError {
    #[error("HireSpecialistError: Executing player does not exist")]
    ExecutingPlayerDoesNotExist(i64),
}

impl From<HireSpecialistError> for PlayerActionHandlingError {
    fn from(value: HireSpecialistError) -> Self {
        Self::HireSpecialistV1Error(value)
    }
}

impl HireSpecialistError {
    fn into_system_error(self) -> PlayerActionHandlingError {
        PlayerActionHandlingError::HireSpecialistV1Error(self)
    }
}

impl ActionHandler for Handler {
    fn handler_id(&self) -> String {
        "hire_specialist/v_1".to_string()
    }
    fn accepts_action(&self, action: &PlayerActionVariant) -> bool {
        match action {
            PlayerActionVariant::HireSpecialist { .. } => true,
            _ => false,
        }
    }
    fn action_is_valid(
        &self,
        world: &World,
        action: &PlayerAction,
    ) -> Result<(), PlayerActionHandlingError> {
        world.players.get(&action.executing_player).ok_or(
            HireSpecialistError::ExecutingPlayerDoesNotExist(action.executing_player.to_owned()),
        )?;

        let queen = world.specialists.iter().find(|(_, spec)| {
            match (spec.owner.as_player_owned(), spec.variant.as_queen()) {
                (Some(owner_id), Some(queen_state)) => (owner_id == *action.executing_player),
                _ => false,
            }
        });

        Ok(())
    }
    fn handle(
        &self,
        world: &mut World,
        action: &PlayerAction,
    ) -> Result<(), PlayerActionHandlingError> {
        todo!()
    }
}
