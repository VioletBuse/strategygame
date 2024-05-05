use enum_as_inner::EnumAsInner;
use thiserror::Error;
use crate::entities::specialist;
use crate::entities::world::World;
use crate::systems::{SystemHandler, SystemHandlingError};

#[derive(Clone)]
pub struct Handler;

#[derive(Clone, Debug, PartialEq, EnumAsInner, Error)]
pub enum QueenHiringOptionsGenError {
    #[error("QueenHiringOptionsGenerator: There are more choices to generate than specialists")]
    MoreChoicesToGenThanSpecVariants
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
        for (_, spec) in world.specialists.iter_mut() {
            let ticks_per_queen_incr = world.config.ticks_till_next_specialist_hire_incr;
            let choices_to_generate = world.config.specialist_hire_choice_count;

            match spec.variant.as_queen_mut() {
                Some(queen_state) => {
                    let generating_tick = queen_state.ticks_since_last_incr >= ticks_per_queen_incr as u64;
                    if generating_tick {
                        queen_state.hiring_slots += 1;
                        let mut choices = vec![];
                        let mut possible_choices = specialist::SpecialistVariant::generate_defaults();

                        for _ in 0..choices_to_generate {
                            if possible_choices.len() == 0 {
                                return Err(QueenHiringOptionsGenError::MoreChoicesToGenThanSpecVariants.to_system_error());
                            }

                            let index = (rand::random::<f32>() * possible_choices.len() as f32).floor() as usize;
                            choices.push(possible_choices.swap_remove(index));
                        }

                        queen_state.next_hires.push_back(choices);
                    }
                }
                None => continue,
            }
        }

        Ok(())
    }
}
