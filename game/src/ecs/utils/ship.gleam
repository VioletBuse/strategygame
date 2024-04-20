import gleam/list
import ecs/world.{type World}
import ecs/entities/ships.{type Ship, Ship}

pub fn get_ship(world: World, sid: Int) -> Result(Ship, Nil) {
  case list.find(world.ships, fn(ship) { ship.id == sid }) {
    Ok(ship) -> Ok(ship)
    _ -> Error(Nil)
  }
}

pub fn add_ship(world: World, ship: Ship) -> World {
  todo
}

pub fn delete_ship(world: World, ship: Ship) -> World {
  todo
}

pub fn update_ship(world: World, ship: Ship) -> World {
  todo
}

pub fn add_ships(world: World, new_ships: List(Ship)) -> World {
  todo
}

pub fn delete_ships(world: World, deleted_ships: List(Ship)) -> World {
  todo
}

pub fn update_ships(world: World, updated_ships: List(Ship)) -> World {
  todo
}
