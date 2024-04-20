import gleam/list
import ecs/world.{type World}
import ecs/entities/players.{type Player}
import ecs/entities/outposts
import ecs/entities/ships
import ecs/entities/specialists

pub fn get(world: World, pid: Int) -> Result(Player, Nil) {
  case list.find(world.players, fn(player) { player.id == pid }) {
    Ok(player) -> Ok(player)
    _ -> Error(Nil)
  }
}

pub fn list_outposts(world: World, player: Player) -> List(outposts.Outpost) {
  list.filter(world.outposts, fn(outpost) {
    case outpost.ownership {
      outposts.PlayerOwned(pid) -> pid == player.id
      _ -> False
    }
  })
}

pub fn list_ships(world: World, player: Player) -> List(ships.Ship) {
  list.filter(world.ships, fn(ship) {
    case ship.ownership {
      ships.PlayerOwned(pid) -> pid == player.id
      _ -> False
    }
  })
}

pub fn list_specialists(
  world: World,
  player: Player,
) -> List(specialists.Specialist) {
  list.filter(world.specialists, fn(specialist) {
    specialist.ownership.id == player.id
  })
}

pub fn add_player(world: World, player: Player) -> World {
  todo
}

pub fn update_player(world: World, player: Player) -> World {
  todo
}

pub fn delete_player(world: World, player: Player) -> World {
  todo
}

pub fn add_players(world: World, players: List(Player)) -> World {
  todo
}

pub fn update_players(world: World, players: List(Player)) -> World {
  todo
}

pub fn delete_players(world: World, players: List(Player)) -> World {
  todo
}
