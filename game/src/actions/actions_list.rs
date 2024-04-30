use derive_new::new;
use enum_as_inner::EnumAsInner;
use typed_builder::TypedBuilder;

#[derive(Clone, Debug, TypedBuilder)]
pub struct PlayerAction {
    pub executing_player: i64,
    pub player_action: PlayerActionVariant,
}

#[derive(Clone, Debug, EnumAsInner, new)]
pub enum PlayerActionEntityRef {
    OutpostRef(i64),
    PlayerRef(i64),
    SpecialistRef(i64),
    ShipRef(i64),
}

#[derive(Clone, Debug, EnumAsInner, new)]
pub enum PlayerActionVariant {
    SendShip {
        from: i64,
        target: PlayerActionEntityRef,
        specs: Vec<PlayerActionEntityRef>,
        units: u64,
    },
}
