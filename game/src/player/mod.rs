
#[derive(Debug, Clone)]
pub struct PlayerData {
    id: String,
    trans: bool
}

#[derive(Debug, Clone)]
pub enum Player {
    Player(PlayerData)
}

impl Player {
    pub fn collect(&mut self, transition: Transition) {
        match (self, transition) {
            (Player::Player(data), Transition::TransPlayerGender) => { data.trans = !data.trans; }
        }
    }
    pub fn data_mut(&mut self) -> &mut PlayerData {
        match self {
            Player::Player(data) => data
        }
    }
}

#[derive(Debug, Clone)]
pub enum Transition {
    TransPlayerGender
}

