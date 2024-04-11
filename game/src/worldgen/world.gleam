import gleam/list
import gleam/dict
import gleam/order
import gleam/float
import gleam/int
import gleam/result
import worldgen/min_points
import worldgen/grid_utils

pub type WorldgenOutpost =
  #(WorldgenOutpostData, Float, Float)

pub type GeneratedOutpostType {
  GeneratedFactory
  GeneratedGenerator
}

pub type WorldgenOutpostData {
  OwnedOutpost(
    id: Int,
    outpost_type: GeneratedOutpostType,
    player_id: Int,
    queen_spawn: Bool,
  )
  UnownedOutpost(id: Int, outpost_type: GeneratedOutpostType)
}

type AdjacencyMatrix =
  List(#(dict.Dict(Int, Float), #(Float, Float)))

pub fn generate_world(
  players: Int,
  starting_gen starting_gen: Int,
  starting_fac starting_fac: Int,
  remaining remaining: Int,
  gen_fac_ratio gen_fac_ratio: Float,
) -> Result(List(#(WorldgenOutpostData, Float, Float)), Nil) {
  let starting = starting_gen + starting_fac
  let per_player = starting + remaining

  let world_points = min_points.generate(players * per_player, False)
  let spawn_points = min_points.generate(players, True)

  case world_points, spawn_points {
    Ok(world_points), Ok(player_spawn_points) -> {
      let user_int_ids = list.range(1, players)
      let assigned_spawn_points = list.zip(user_int_ids, player_spawn_points)

      let adjacency_matrix: AdjacencyMatrix = {
        world_points
        |> list.map(fn(world_point) {
          let distances = {
            assigned_spawn_points
            |> list.map(fn(s) {
              let #(player_id, spawn_point) = s
              #(
                player_id,
                grid_utils.point_distance(#(1, 1), world_point, spawn_point),
              )
            })
            |> list.filter(fn(a) { result.is_ok(a.1) })
            |> list.map(fn(v) {
              case v {
                #(id, Ok(dist)) -> #(id, dist)
                _ -> panic as "distance should not be errored"
              }
            })
            |> dict.from_list
          }

          #(distances, world_point)
        })
      }

      let assigned =
        assign_outpost_loop(assigned_spawn_points, adjacency_matrix, starting)

      let assignments_with_outpost_type =
        assign_outpost_type_loop(
          assigned,
          starting_gen: starting_gen,
          starting_fac: starting_fac,
          gen_fac_ratio: gen_fac_ratio,
        )

      assignments_with_outpost_type

      assign_outpost_loop(assigned_spawn_points, adjacency_matrix, starting)
      |> assign_outpost_type_loop(
        starting_gen: starting_gen,
        starting_fac: starting_fac,
        gen_fac_ratio: gen_fac_ratio,
      )
      |> assign_queen_spawn_outpost_loop()
      |> list.map(fn(assignment) {
        case assignment {
          #(#(-1, outpost_type, _), point) -> #(
            UnownedOutpost(
              id: int.random(1_000_000_000),
              outpost_type: outpost_type,
            ),
            point.0,
            point.1,
          )
          #(#(player_id, outpost_type, queen_spawn), point) -> #(
            OwnedOutpost(
              id: int.random(1_000_000_000),
              outpost_type: outpost_type,
              player_id: player_id,
              queen_spawn: queen_spawn,
            ),
            point.0,
            point.1,
          )
        }
      })
      |> Ok
    }
    _, _ -> Error(Nil)
  }
}

fn assign_outpost_loop(
  spawn_points: List(#(Int, #(Float, Float))),
  outposts: AdjacencyMatrix,
  starting_outpost_count: Int,
) -> List(#(Int, #(Float, Float))) {
  list.range(1, starting_outpost_count)
  |> list.map(fn(_) { spawn_points })
  |> list.concat
  |> list.shuffle
  |> assign_outposts_inner_loop(outposts)
}

fn assign_outposts_inner_loop(
  spawn_points_assignment_list: List(#(Int, #(Float, Float))),
  outposts: AdjacencyMatrix,
) -> List(#(Int, #(Float, Float))) {
  case spawn_points_assignment_list {
    [] -> {
      outposts
      |> list.map(fn(pst) {
        let #(_, #(x, y)) = pst
        #(-1, #(x, y))
      })
    }
    [current_spawn_point, ..rest_spawns] -> {
      let closest_points =
        list.sort(outposts, fn(first, second) {
          let first_dist = dict.get(first.0, current_spawn_point.0)
          let second_dist = dict.get(second.0, current_spawn_point.0)

          case first_dist, second_dist {
            Ok(first), Ok(second) -> float.compare(first, second)
            Ok(_), _ -> order.Gt
            _, Ok(_) -> order.Lt
            _, _ -> order.Eq
          }
        })

      case closest_points {
        [] -> []
        [first, ..rest_world_points] -> {
          let #(_, #(x, y)) = first
          [
            #(current_spawn_point.0, #(x, y)),
            ..assign_outposts_inner_loop(rest_spawns, rest_world_points)
          ]
        }
      }
    }
  }
}

fn assign_outpost_type_loop(
  pregenerated_outposts: List(#(Int, #(Float, Float))),
  starting_gen starting_gen: Int,
  starting_fac starting_fac: Int,
  gen_fac_ratio gen_fac_ratio: Float,
) -> List(#(#(Int, GeneratedOutpostType), #(Float, Float))) {
  let grouped =
    list.group(pregenerated_outposts, fn(v) {
      let #(assignment, _) = v
      assignment
    })

  dict.keys(grouped)
  |> list.map(fn(owner) {
    case owner {
      -1 -> {
        let assert Ok(outpost_list) = dict.get(grouped, -1)
        list.map(outpost_list, fn(outpost) {
          let #(owner, point) = outpost
          let outpost_type = case float.random() {
            value if value >=. gen_fac_ratio -> GeneratedFactory
            _ -> GeneratedGenerator
          }

          #(#(owner, outpost_type), point)
        })
      }
      owner -> {
        let assert Ok(outpost_list) = dict.get(grouped, owner)
        let types_to_dist =
          list.concat([
            list.range(1, starting_gen)
              |> list.map(fn(_) { GeneratedGenerator }),
            list.range(1, starting_fac)
              |> list.map(fn(_) { GeneratedFactory }),
          ])
          |> list.shuffle

        let shuffled_outposts = list.shuffle(outpost_list)

        let #(_, new_list) =
          list.map_fold(
            shuffled_outposts,
            types_to_dist,
            fn(remaining_types, outpost) {
              case remaining_types {
                [] -> panic as "no outposts remaining to distribute"
                [current, ..rest] -> #(rest, #(#(owner, current), outpost.1))
              }
            },
          )

        new_list
      }
    }
  })
  |> list.concat
}

fn assign_queen_spawn_outpost_loop(
  outposts: List(#(#(Int, GeneratedOutpostType), #(Float, Float))),
) -> List(#(#(Int, GeneratedOutpostType, Bool), #(Float, Float))) {
  let grouped =
    list.group(outposts, fn(v) {
      let #(#(id, _), _) = v
      id
    })

  dict.keys(grouped)
  |> list.map(fn(owner) {
    case owner {
      -1 -> {
        let assert Ok(outpost_list) = dict.get(grouped, owner)

        outpost_list
        |> list.map(fn(specific_outpost) {
          let #(#(owner, outpost_type), point) = specific_outpost
          #(#(owner, outpost_type, False), point)
        })
      }
      owner -> {
        let assert Ok(outpost_list) = dict.get(grouped, owner)

        let outposts_sorted =
          outpost_list
          |> list.map(fn(specific_outpost) {
            let #(#(owner, outpost_type), point) = specific_outpost

            let squared_distances =
              list.map(outpost_list, fn(other_outpost) {
                let #(_, other_outpost_pos) = other_outpost
                case
                  grid_utils.point_distance(#(1, 1), point, other_outpost_pos)
                {
                  Ok(distance) -> {
                    let assert Ok(squared) = float.power(distance, 2.0)
                    squared
                  }
                  Error(_) -> 9.0
                }
              })
              |> list.fold(0.0, fn(acc, dist) { acc +. dist })

            #(#(owner, outpost_type, squared_distances), point)
          })
          |> list.sort(fn(first, second) {
            let #(#(_, _, first_dist), _) = first
            let #(#(_, _, second_dist), _) = second

            float.compare(first_dist, second_dist)
          })

        case outposts_sorted {
          [] -> []
          [first, ..rest] -> {
            let #(#(first_owner, first_outpost_type, _), first_pos) = first
            let first_outpost = #(
              #(first_owner, first_outpost_type, True),
              first_pos,
            )

            let rest_outposts =
              list.map(rest, fn(v) {
                let #(#(owner, outpost_type, _), position) = v
                #(#(owner, outpost_type, False), position)
              })

            list.concat([[first_outpost], rest_outposts])
          }
        }
      }
    }
  })
  |> list.concat
}
