import ecs/entities/players.{type Player}
import ecs/entities/outposts.{type Outpost}
import ecs/entities/ships.{type Ship}
import ecs/entities/specialists.{type Specialist}

pub type World {
  // World(
  //   server_side: Bool,
  //   size: Int,
  //   for_player: Int,
  //   base_units_per_tick: Int,
  //   base_units_per_gen: Int,
  //   players: List(Player),
  //   outposts: List(Outpost),
  //   ships: List(Ship),
  //   specialists: List(Specialist),
  // )
  ServerWorld(
    size: Int,
    players: List(Player),
    outposts: List(Outpost),
    ships: List(Ship),
    specialists: List(Specialist),
    base_units_per_tick: Int,
    base_units_per_gen: Int,
  )
  ClientWorld(
    size: Int,
    players: List(Player),
    outposts: List(Outpost),
    ships: List(Ship),
    specialists: List(Specialist),
    base_units_per_tick: Int,
    base_units_per_gen: Int,
    for_player: Int,
  )
}
