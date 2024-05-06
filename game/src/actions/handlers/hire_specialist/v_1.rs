use enum_as_inner::EnumAsInner;
use thiserror::Error;

use crate::actions::PlayerActionHandlingError;

use enum_as_inner::EnumAsInner;

#[derive(Clone)]
pub struct Handler;

#[derive(Error, Clone, Debug, PartialEq, EnumAsInner)]
pub enum HireSpecialistError {}

impl From<HireSpecialistError> for PlayerActionHandlingError {
    fn from(value: HireSpecialistError) -> Self {
        Self::HireSpecialistV1Error(value)
    }
}
