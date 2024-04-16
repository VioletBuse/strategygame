import gleam/list
import ecs/world.{type World}
import ecs/entities/specialists.{type Specialist}
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
