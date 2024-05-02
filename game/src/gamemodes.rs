use derive_new::new;
use enum_as_inner::EnumAsInner;

use crate::entities::world::WorldConfig;

#[derive(Clone, Debug, PartialEq, EnumAsInner, new)]
pub enum GameMode {
    Standard,
    Quickplay,
    Blitz,
}

impl From<GameMode> for WorldConfig {
    fn from(value: GameMode) -> Self {
        match value {
            GameMode::Standard => {
                let mut config = WorldConfig::default();

                config
            }
            GameMode::Quickplay => {
                let mut config = WorldConfig::default();

                config
            }
            GameMode::Blitz => {
                let mut config = WorldConfig::default();

                config.target_ship_pirate_required = false;

                config
            }
        }
    }
}
