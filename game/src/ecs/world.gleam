import prng/seed.{type Seed}
import ecs/entities/players.{type Player}
import ecs/entities/outposts.{type Outpost}
import ecs/entities/ships.{type Ship}
import ecs/entities/specialists.{type Specialist}

pub type World {
  World(
    seed: Seed,
    size: Float,
    players: List(Player),
    outposts: List(Outpost),
    ships: List(Ship),
    specialists: List(Specialist),
  )
}

pub fn initialize_world(seed seed: Int, size size: Float) -> World {
  World(
    seed: seed.new(seed),
    size: size,
    players: [],
    outposts: [],
    ships: [],
    specialists: [],
  )
}
