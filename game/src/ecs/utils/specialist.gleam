import gleam/list
import ecs/world.{type World, World}
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
  World(..world, specialists: [specialist, ..world.specialists])
}

pub fn update_specialist(world: World, updated_specialist: Specialist) -> World {
  let updated_specialists =
    list.map(world.specialists, fn(curr_specialist) {
      case curr_specialist {
        Specialist(id, _, _, _) if id == updated_specialist.id ->
          updated_specialist
        _ -> curr_specialist
      }
    })

  World(..world, specialists: updated_specialists)
}
