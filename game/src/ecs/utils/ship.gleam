import gleam/list
import ecs/world.{type World}
import ecs/entities/ships.{type Ship}

pub fn get(world: World, sid: Int) -> Result(Ship, Nil) {
  case list.find(world.ships, fn(ship) { ship.id == sid }) {
    Ok(ship) -> Ok(ship)
    _ -> Error(Nil)
  }
}
