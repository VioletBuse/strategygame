use derive_new::new;
use enum_as_inner::EnumAsInner;
use typed_builder::TypedBuilder;

#[derive(Clone, Debug, TypedBuilder)]
pub struct PlayerAction {
    executing_player: i64,
    tick: u64,
    variant: PlayerActionVariant,
}

#[derive(Clone, Debug, EnumAsInner, new)]
pub enum PlayerActionVariant {
    PromoteQueen,
}
