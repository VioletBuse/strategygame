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
    Outpost(i64),
    Player(i64),
    Specialist(i64),
    Ship(i64),
}

#[derive(Clone, Debug, EnumAsInner, new)]
pub enum PlayerActionVariant {
    SendShip {
        from: i64,
        target: PlayerActionEntityRef,
        specs: Vec<PlayerActionEntityRef>,
        units: u64,
    },
    RedirectShip {
        ship_id: i64,
    },
}
