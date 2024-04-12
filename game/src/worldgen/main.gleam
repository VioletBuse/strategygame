import gleam/list
import gleam/dict
import gleam/result
import ecs/entities/outposts
import worldgen/world
import worldgen/grid_utils

pub type WorldgenPreset {
  Standard(player_ids: List(Int))
}

pub type WorldgenResult {
  WorldgenResult(outposts: List(outposts.Outpost))
}

pub fn create(preset: WorldgenPreset) -> Result(WorldgenResult, Nil) {
  case preset {
    Standard(player_ids) -> {
      let player_count = list.length(player_ids)
      let generation =
        world.generate_world(player_count, 2, 3, 11, 0.4)
        |> result.map(grid_utils.scale_exported_grid_to_size_with_ids(_, 300))

      let grouped_outposts =
        result.map(generation, list.group(_, fn(outpost) {
          case outpost {
            #(world.OwnedOutpost(owner, _, _, _), _, _) -> owner
            _ -> -1
          }
        }))

      use grouping <- result.map(grouped_outposts)
      let mapped_outposts =
        dict.keys(grouping)
        |> list.map(fn(pre_owner_id) {
          case pre_owner_id {
            -1 -> #(-1, -1)
            pre ->
              case list.at(player_ids, pre - 1) {
                Ok(player_id) -> #(pre_owner_id, player_id)
                _ ->
                  panic as "there should be the same number of player ids and pre assignment ids"
              }
          }
        })
        |> list.map(fn(ids) {
          case ids {
            #(-1, _) -> {
              let assert Ok(outpost_list) = dict.get(grouping, -1)

              outpost_list
              |> list.map(fn(outpost) {
                let assert #(
                  world.UnownedOutpost(outpost_id, outpost_type),
                  x,
                  y,
                ) = outpost

                let new_outpost_type = case outpost_type {
                  world.GeneratedFactory -> outposts.Factory
                  world.GeneratedGenerator -> outposts.Generator
                }
                outposts.Outpost(
                  outpost_id,
                  new_outpost_type,
                  outposts.OutpostLocation(x, y),
                  outposts.Unowned,
                )
              })
            }
            #(dict_key, player_id) -> {
              let assert Ok(outpost_list) = dict.get(grouping, dict_key)

              outpost_list
              |> list.map(fn(outpost) {
                let assert #(
                  world.OwnedOutpost(outpost_id, outpost_type, _, _),
                  x,
                  y,
                ) = outpost

                let new_outpost_type = case outpost_type {
                  world.GeneratedFactory -> outposts.Factory
                  world.GeneratedGenerator -> outposts.Generator
                }

                outposts.Outpost(
                  outpost_id,
                  new_outpost_type,
                  outposts.OutpostLocation(x, y),
                  outposts.Player(player_id),
                )
              })
            }
          }
        })
        |> list.concat

      WorldgenResult(mapped_outposts)
    }
  }
}
