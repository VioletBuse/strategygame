use enum_as_inner::EnumAsInner;

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, EnumAsInner)]
pub enum OutpostVariant {
    Generator,
    Factory,
    Mine,
    Ruin,
    Unknown,
}

impl From<String> for OutpostVariant {
    fn from(value: String) -> Self {
        match value.as_str() {
            "gen" | "generator" | "Gen" | "Generator" | "GENERATOR" => OutpostVariant::Generator,
            "fac" | "factory" | "Fac" | "Factory" | "FACTORY" => OutpostVariant::Factory,
            "mine" | "Mine" | "MINE" => OutpostVariant::Mine,
            "ruin" | "Ruin" | "RUIN" => OutpostVariant::Ruin,
            _ => OutpostVariant::Unknown,
        }
    }
}

impl OutpostVariant {
    pub fn new_generator() -> OutpostVariant {
        OutpostVariant::Generator
    }
    pub fn to_generator(self) -> OutpostVariant {
        OutpostVariant::Generator
    }
    pub fn new_factory() -> OutpostVariant {
        OutpostVariant::Factory
    }
    pub fn to_factory(self) -> OutpostVariant {
        OutpostVariant::Factory
    }
    pub fn new_mine() -> OutpostVariant {
        OutpostVariant::Mine
    }
    pub fn to_mine(self) -> OutpostVariant {
        OutpostVariant::Mine
    }
    pub fn new_ruin() -> OutpostVariant {
        OutpostVariant::Ruin
    }
    pub fn to_ruin() -> OutpostVariant {
        OutpostVariant::Ruin
    }

    pub fn new_unknown() -> OutpostVariant {
        OutpostVariant::Unknown
    }
    pub fn to_unknown() -> OutpostVariant {
        OutpostVariant::Unknown
    }
}
