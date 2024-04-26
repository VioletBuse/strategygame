pub mod hire_specialist;


#[derive(Clone, Debug)]
pub enum PlayerAction {
    HireSpecialist { player_id: String, selection: u8 }
}
