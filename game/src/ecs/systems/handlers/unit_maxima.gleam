import gleam/list
import ecs/world.{type World}
import ecs/entities/players
import ecs/entities/outposts
import ecs/utils/player

pub fn handler(world: World) -> Result(World, Nil) {
  let updated_players =
    world.players
    |> list.map(fn(player) {
      let outposts = player.list_outposts(world, player)
      let base_unit_maximum =
        list.fold(outposts, 0, fn(acc, outpost) {
          case outpost.outpost_type {
            outposts.Generator -> acc + world.base_units_per_gen
            _ -> acc
          }
        })

      players.Player(..player, unit_capacity: base_unit_maximum)
    })

  Ok(world.World(..world, players: updated_players))
}
