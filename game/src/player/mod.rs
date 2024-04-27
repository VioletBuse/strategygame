use enum_as_inner::EnumAsInner;

#[derive(Debug, Clone)]
pub struct PlayerData {
    id: String,
    trans: bool,
}

#[derive(Debug, Clone, EnumAsInner)]
pub enum Player {
    Player(PlayerData)
}

pub type PlayerStateResult = Result<(), PlayerError>;

pub enum PlayerError {
    InvalidPlayerType,
    PlayerAlreadyTrans
}

impl Player {
    pub fn collect(&mut self, transition: Transition) -> PlayerStateResult {
        match transition {
            Transition::TransPlayerGender => handle_transing_gender(self, transition)
        }
    }
}

fn handle_transing_gender(player: &mut Player, transition: Transition) -> PlayerStateResult {
    match player.as_player_mut() {
        Some(inner) => {
            if inner.trans {
                return Err(PlayerError::PlayerAlreadyTrans);
            }
            
            inner.trans = true;
            
            Ok(())
        }
        None => Err(PlayerError::InvalidPlayerType)
    }
}

#[derive(Debug, Clone)]
pub enum Transition {
    TransPlayerGender
}

