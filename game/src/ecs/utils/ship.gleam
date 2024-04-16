import gleam/list
import ecs/world.{type World, World}
import ecs/entities/ships.{type Ship, Ship}

pub fn get(world: World, sid: Int) -> Result(Ship, Nil) {
  case list.find(world.ships, fn(ship) { ship.id == sid }) {
    Ok(ship) -> Ok(ship)
    _ -> Error(Nil)
  }
}

pub fn add_ship(world: World, ship: Ship) -> World {
  World(..world, ships: [ship, ..world.ships])
}

pub fn update_ship(world: World, updated_ship: Ship) -> World {
  let new_ships =
    world.ships
    |> list.map(fn(ship) {
      case ship {
        Ship(id, _, _, _, _) if id == updated_ship.id -> updated_ship
        curr_ship -> curr_ship
      }
    })

  World(..world, ships: new_ships)
}

pub fn delete_ship(world: World, deleted_ship: Ship) -> World {
  let new_ships =
    world.ships
    |> list.fold([], fn(acc, ship) {
      case ship {
        Ship(id, _, _, _, _) if id == deleted_ship.id -> acc
        curr_ship -> [curr_ship, ..acc]
      }
    })

  World(..world, ships: new_ships)
}
