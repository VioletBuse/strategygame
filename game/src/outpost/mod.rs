#[derive(Debug, Clone)]
pub struct OutpostData {
    id: String,
    units: u16,
}

#[derive(Debug, Clone)]
pub enum Outpost {
    Generator(OutpostData),
    Factory(OutpostData),
    Mine(OutpostData),
    Wreck(OutpostData),
}

impl Outpost {
    pub fn collect(&mut self, outpost_transition: Transition) {
        match (self, outpost_transition) {
            (Outpost::Generator(data), Transition::PromoteToMine(units_required))
            if data.units >= units_required => { *self = Outpost::Mine(data.clone()) }
            (Outpost::Factory(data), Transition::PromoteToMine(units_required))
            if data.units >= units_required => { *self = Outpost::Mine(data.clone()) }
            (_, Transition::PromoteToMine(_)) => {}
            (current_outpost, Transition::DemoteToWreck) => {
                let data = current_outpost.data_mut();
                data.units = 0;

                *self = Outpost::Wreck(data.clone())
            }
        }
    }
    fn data_mut(&mut self) -> &mut OutpostData {
        match self {
            Outpost::Generator(data) => data,
            Outpost::Factory(data) => data,
            Outpost::Mine(data) => data,
            Outpost::Wreck(data) => data
        }
    }
    pub fn data(&self) -> OutpostData {
        match self {
            Outpost::Generator(data) => data.clone(),
            Outpost::Factory(data) => data.clone(),
            Outpost::Mine(data) => data.clone(),
            Outpost::Wreck(data) => data.clone()
        }
    }
}

pub enum Transition {
    PromoteToMine(u16),
    DemoteToWreck,
}

