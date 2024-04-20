import ecs/entities/players.{type Player}
import ecs/entities/outposts.{type Outpost}
import ecs/entities/ships.{type Ship}
import ecs/entities/specialists.{type Specialist}

pub type World {
  World(
    world_type: WorldType,
    current_tick: Int,
    size: Int,
    players: List(Player),
    outposts: List(Outpost),
    ships: List(Ship),
    specialists: List(Specialist),
    base_units_per_tick: Int,
    base_units_per_gen: Int,
  )
}

pub type WorldType {
  ServerWorld
  ClientWorld(for_player: Int)
}
