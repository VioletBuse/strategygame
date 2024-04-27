
#[derive(Debug, Clone)]
pub struct SpecData {
    id: String,
}

#[derive(Debug, Clone)]
pub enum Spec {
    Queen(SpecData),
    Princess(SpecData),
    Pirate(SpecData),
    Navigator(SpecData),
    Helmsman(SpecData),
}

impl Spec {
    pub fn collect(&mut self, spec_transition: Transition) {
        match (self, spec_transition) {
            (Spec::Princess(data), Transition::PromotePrincessToQueen) =>
                { *self = Spec::Queen(data.clone()) }
            (_, Transition::PromotePrincessToQueen) => {}
            (Spec::Navigator(data), Transition::PromoteNavigatorToHelmsman) =>
                { *self = Spec::Helmsman(data.clone()) }
            (_, Transition::PromoteNavigatorToHelmsman) => {}
        }
    }
}

#[derive(Debug, Clone)]
pub enum Transition {
    PromotePrincessToQueen,
    PromoteNavigatorToHelmsman,
}

