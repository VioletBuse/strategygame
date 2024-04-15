import ecs/entities/players.{type Player}
import ecs/entities/outposts.{type Outpost}
import ecs/entities/ships.{type Ship}
import ecs/entities/specialists.{type Specialist}

pub type World {
  World(
    players: List(Player),
    outposts: List(Outpost),
    ships: List(Ship),
    specialists: List(Specialist),
  )
}
