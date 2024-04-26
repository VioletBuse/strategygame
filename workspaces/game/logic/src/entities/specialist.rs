
#[derive(Clone, Debug)]
pub enum Variant {
    Queen{upcoming_hires: Vec<Vec<Variant>>, hires_available: u16, ticks_since_update: u32},
    Princess,
    Navigator,
    Pirate
}

#[derive(Clone, Debug)]
pub enum Owner {
    PlayerOwned{player_id: String},
    Unowned
}

#[derive(Clone, Debug)]
pub enum Location {
    Outpost{outpost_id: String},
    Ship{ship_id: String}
}

#[derive(Clone, Debug)]
pub struct Specialist {
    pub id: String,
    pub variant: Variant,
    pub owner: Owner,
    pub location: Location
}

impl Specialist {
    pub fn is_queen(&self) -> bool {
        match self.variant {
            Variant::Queen {..} => true,
            _ => false
        }
    }
}
