
#[derive(Debug, Clone)]
pub struct ShipData {
    id: String
}

#[derive(Debug, Clone)]
pub enum ShipState {
    Ship(ShipData)
}

impl ShipState {
    pub fn collect(&mut self, ship_transition: ShipTransition) {
        match (self, ship_transition) {
            _ => {}
        }
    }
}

#[derive(Debug, Clone)]
pub enum ShipTransition {}

