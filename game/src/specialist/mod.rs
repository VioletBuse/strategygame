use enum_as_inner::EnumAsInner;

#[derive(Default, Debug, Clone)]
pub struct SpecData {
    id: String,
}

#[derive(Debug, Clone, EnumAsInner)]
pub enum Spec {
    Queen(SpecData),
    Princess(SpecData),
    Pirate(SpecData),
    Navigator(SpecData),
    Helmsman(SpecData),
}

pub type SpecStateResult = Result<(), SpecialistError>;

pub enum SpecialistError {
    InvalidSpecForPromo
}

impl Spec {
    pub fn collect(&mut self, transition: Transition) -> SpecStateResult {
        match transition {
            Transition::PromotePrincessToQueen => handle_princess_to_queen_promo(self, transition),
            Transition::PromoteNavigatorToHelmsman => handle_nav_to_helmsman_promo(self, transition)
        }
    }
}

fn handle_princess_to_queen_promo(spec: &mut Spec, transition: Transition) -> SpecStateResult {
    match spec.as_princess_mut() {
        Some(curr) => {
            let inner = std::mem::take(curr);
            *spec = Spec::Queen(inner);
            Ok(())
        }
        None => Err(SpecialistError::InvalidSpecForPromo)
    }
}

fn handle_nav_to_helmsman_promo(spec: &mut Spec, transition: Transition) -> SpecStateResult {
    match spec.as_navigator_mut() {
        Some(curr) => {
            let inner = std::mem::take(curr);
            *spec = Spec::Helmsman(inner);
            Ok(())
        }
        None => Err(SpecialistError::InvalidSpecForPromo)
    }
}

#[derive(Debug, Clone)]
pub enum Transition {
    PromotePrincessToQueen,
    PromoteNavigatorToHelmsman,
}

