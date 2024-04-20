import gleam/list
import ecs/world.{type World}
import ecs/entities/specialists.{type Specialist, Specialist}
import ecs/entities/players

pub fn get(world: World, sid: Int) -> Result(Specialist, Nil) {
  case list.find(world.specialists, fn(specialist) { specialist.id == sid }) {
    Ok(specialist) -> Ok(specialist)
    _ -> Error(Nil)
  }
}

pub fn owner(
  world: World,
  specialist: Specialist,
) -> Result(players.Player, Nil) {
  case
    list.find(world.players, fn(player) { player.id == specialist.ownership.id })
  {
    Ok(player) -> Ok(player)
    _ -> Error(Nil)
  }
}

pub fn add_specialist(world: World, specialist: Specialist) -> World {
  todo
}

pub fn update_specialist(world: World, specialist: Specialist) -> World {
  todo
}

pub fn delete_specialist(world: World, specialist: Specialist) -> World {
  todo
}

pub fn add_specialists(world: World, specialists: List(Specialist)) -> World {
  todo
}

pub fn update_specialists(world: World, specialists: List(Specialist)) -> World {
  todo
}

pub fn delete_specialists(world: World, specialists: List(Specialist)) -> World {
  todo
}
