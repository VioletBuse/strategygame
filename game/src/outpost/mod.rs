mod owner;

use enum_as_inner::EnumAsInner;

#[derive(Default, Debug, Clone)]
pub struct OutpostData {
    id: String,
    units: u32,
}

#[derive(Debug, Clone, EnumAsInner)]
pub enum Outpost {
    Generator(OutpostData),
    Factory(OutpostData),
    Mine(OutpostData),
    Wreck(OutpostData),
}

pub type OutpostStateResult = Result<(), OutpostError>;

pub enum OutpostError {
    NotEnoughUnitsToPromo,
    InvalidOutpostType,
    InvalidTransition,
}

impl Outpost {
    pub fn collect(&mut self, transition: Transition) -> OutpostStateResult {
        match transition {
            Transition::PromoteToMine(_) => handle_promo_to_mine(self, transition),
            Transition::DemoteToWreck => handle_demo_to_wreck(self, transition)
        }
    }
}

fn handle_promo_to_mine(outpost: &mut Outpost, transition: Transition) -> OutpostStateResult {
    if (!transition.is_promote_to_mine()) {
        return Err(OutpostError::InvalidTransition);
    }

    let mut curr = match outpost {
        Outpost::Generator(inner) => inner,
        Outpost::Factory(inner) => inner,
        Outpost::Mine(inner) => inner,
        Outpost::Wreck(_) => return Err(OutpostError::InvalidOutpostType)
    };

    let units_required = *transition.as_promote_to_mine().ok_or(OutpostError::InvalidTransition)?;
    if (curr.units < units_required) {
        return Err(OutpostError::NotEnoughUnitsToPromo);
    }

    curr.units -= units_required;
    let inner = std::mem::take(curr);
    *outpost = Outpost::Mine(inner);

    Ok(())
}


fn handle_demo_to_wreck(outpost: &mut Outpost, transition: Transition) -> OutpostStateResult {
    if !transition.is_demote_to_wreck() { return Err(OutpostError::InvalidTransition); }

    let curr = outpost.as_mine_mut()
        .or(outpost.as_factory_mut())
        .or(outpost.as_mine_mut())
        .ok_or(OutpostError::InvalidOutpostType)?;

    let inner = std::mem::take(curr);
    *outpost = Outpost::Wreck(inner);

    Ok(())
}

#[derive(Debug, Clone, EnumAsInner)]
pub enum Transition {
    PromoteToMine(u32),
    DemoteToWreck,
}

