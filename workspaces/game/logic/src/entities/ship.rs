
#[derive(Clone, Debug)]
pub enum Owner {
    PlayerOwned(String),
    Unowned
}

#[derive(Clone, Debug)]
pub enum Target {
    Outpost{ outpost_id: String},
    Ship{ship_id: String},
    Unknown{heading: f32}
}

#[derive(Clone, Debug)]
pub struct Ship {
    pub id: String,
    pub x: f32,
    pub y: f32,
    pub owner: Owner,
    pub target: Target,
    pub units: u32
}

impl Ship {

}
