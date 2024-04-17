import gleam/list
import ecs/world.{type World}
import ecs/entities/specialists
import ecs/entities/players
import ecs/utils/player

pub fn handler(world: World) -> Result(World, Nil) {
  let new_players =
    world.players
    |> list.map(fn(player) {
      let queen =
        player.list_specialists(world, player)
        |> list.find(fn(spec) {
          case spec.specialist_type {
            specialists.Queen -> True
            _ -> False
          }
        })

      case queen {
        Ok(_) -> players.Player(..player, alive: True)
        Error(_) -> players.Player(..player, alive: False)
      }
    })

  Ok(world.World(..world, players: new_players))
}
