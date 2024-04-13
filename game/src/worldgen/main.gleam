import gleam/int
import gleam/list
import gleam/dict
import gleam/result
import ecs/entities/outposts
import ecs/entities/players
import ecs/entities/specialists
import ecs/world as ecs_world
import worldgen/world
import worldgen/grid_utils

pub type WorldgenPreset {
  Standard(player_ids: List(Int))
}

pub fn create(preset: WorldgenPreset) -> Result(ecs_world.World, Nil) {
  case preset {
    Standard(player_ids) -> {
      let player_count = list.length(player_ids)

      let players = list.map(player_ids, fn(id) { players.Player(id) })

      let generation =
        world.generate_world(player_count, 2, 3, 11, 0.4)
        |> result.map(grid_utils.scale_exported_grid_to_size_with_ids(_, 300))

      use generated_outposts <- result.map(generation)

      let grouped_outposts =
        list.group(generated_outposts, fn(outpost) {
          case outpost {
            #(world.OwnedOutpost(owner, _, _, _), _, _) -> owner
            _ -> -1
          }
        })

      let mapped_outposts =
        dict.keys(grouped_outposts)
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
              let assert Ok(outpost_list) = dict.get(grouped_outposts, -1)

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
                  stationed_units: 0,
                )
              })
            }
            #(dict_key, player_id) -> {
              let assert Ok(outpost_list) = dict.get(grouped_outposts, dict_key)

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
                  stationed_units: 20,
                )
              })
            }
          }
        })
        |> list.concat

      let resulting_starting_specialists = {
        let generated_with_queen = {
          use outpost <- list.filter(generated_outposts)
          case outpost {
            #(world.OwnedOutpost(_, _, _, True), _, _) -> True
            _ -> False
          }
        }

        use outpost <- list.map(generated_with_queen)
        let assert #(world.OwnedOutpost(outpost_id, _, _, _), _, _) = outpost

        let mapped =
          list.find(mapped_outposts, fn(pst) {
            case pst {
              outposts.Outpost(id, _, _, _, _) if id == outpost_id -> True
              _ -> False
            }
          })

        use found_outpost <- result.try(mapped)
        let assert outposts.Outpost(
          outpost_id,
          _,
          _,
          outposts.Player(player_id),
          _,
        ) = found_outpost
        let new_specialist =
          specialists.Specialist(
            int.random(1_000_000_000),
            specialists.Queen,
            specialists.OutpostLocation(outpost_id),
            specialists.Player(player_id),
          )

        Ok(new_specialist)
      }

      let starting_specialists = result.values(resulting_starting_specialists)

      ecs_world.World(
        outposts: mapped_outposts,
        specialists: starting_specialists,
        players: players,
        ships: [],
      )
    }
  }
}
