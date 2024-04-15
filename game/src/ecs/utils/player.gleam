import gleam/list
import ecs/world.{type World}
import ecs/entities/players.{type Player}

pub fn get(world: World, pid: Int) -> Result(Player, Nil) {
  case list.find(world.players, fn(player) { player.id == pid }) {
    Ok(player) -> Ok(player)
    _ -> Error(Nil)
  }
}
