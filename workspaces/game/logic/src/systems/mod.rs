mod queen_spec_hire;

use crate::world::world::World;

pub enum SystemError {

}

pub fn run_system(world: & mut World, system_fn: fn(& mut World) -> Result<&World, ()>) -> Result<&World, ()> {
    system_fn(world)
}
