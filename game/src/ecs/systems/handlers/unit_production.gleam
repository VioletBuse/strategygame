import gleam/bool
import gleam/list
import ecs/world.{type World}
import ecs/entities/outposts
import ecs/utils/player
import ecs/utils/outpost

pub fn handler(world: World) -> Result(World, Nil) {
  let updated_outposts =
    world.players
    |> list.map(fn(player) {
      let ship_list = player.list_ships(world, player)
      let outpost_list = player.list_outposts(world, player)

      let ships_unit_count =
        list.fold(ship_list, 0, fn(acc, ship) { acc + ship.onboard_units })
      let outpost_unit_count =
        list.fold(outpost_list, 0, fn(acc, outpost) {
          acc + outpost.stationed_units
        })

      let total_player_units = ships_unit_count + outpost_unit_count
      let player_units_maxed = total_player_units >= player.unit_capacity

      use <- bool.guard(player_units_maxed, [])

      outpost_list
      |> list.map(fn(outpost) {
        case outpost.outpost_type {
          outposts.Factory(production_offset) -> {
            let new_type = outposts.Factory(production_offset: 0)
            let new_stationed_units =
              outpost.stationed_units
              + world.base_units_per_tick
              + production_offset

            outposts.Outpost(
              ..outpost,
              outpost_type: new_type,
              stationed_units: new_stationed_units,
            )
          }
          _ -> outpost
        }
      })
    })
    |> list.concat

  Ok(outpost.merge_list(world, updated_outposts))
}
