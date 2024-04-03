import gleam/io
import ecs/world.{type World}
import ecs/systems/unit_production

pub fn main() {
  io.println("Hello from game!")
}

pub fn create_game() -> Nil {
  io.println("created game")
}

pub fn tick_forward(world: World) -> World {
  world
  |> unit_production.run
}
