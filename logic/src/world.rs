use typed_arena::Arena;

use crate::entity::Entity;

pub struct World<'a> {
    entities: Arena<Entity<'a>>,
}
