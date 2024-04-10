import gleam/list
import gleam/dict
import gleam/order
import gleam/float
import gleam/int
import gleam/result
import worldgen/min_points
import worldgen/grid_utils

pub type WorldgenOutpostData {
  OwnedOutpost(id: Int, player_id: Int)
  UnownedOutpost(id: Int)
}

type AdjacencyMatrix =
  List(#(dict.Dict(Int, Float), #(Float, Float)))

pub fn generate_world(
  players: Int,
  per_player per_player: Int,
  starting starting: Int,
) -> Result(List(#(WorldgenOutpostData, Float, Float)), Nil) {
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
              #(player_id, grid_utils.point_distance(world_point, spawn_point))
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

      assigned
      |> list.map(fn(assignment) {
        case assignment {
          #(-1, point) -> #(
            UnownedOutpost(id: int.random(1_000_000_000)),
            point.0,
            point.1,
          )
          #(player_id, point) -> #(
            OwnedOutpost(id: int.random(1_000_000_000), player_id: player_id),
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
