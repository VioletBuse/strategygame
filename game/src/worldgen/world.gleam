import gleam/list
import gleam/dict
import worldgen/min_points
import worldgen/grid_utils

pub type WorldgenOutpostData {
  OwnedOutpost(player_id: Int)
  UnownedOutpost
}

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

      let assigned =
        assign_outpost_loop(assigned_spawn_points, world_points, per_player)

      assigned
      |> list.map(fn(assignment) {
        case assignment {
          #(-1, point) -> #(UnownedOutpost, point.0, point.1)
          #(player_id, point) -> #(
            OwnedOutpost(player_id: player_id),
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
  outposts: List(#(Float, Float)),
  starting_outpost_count: Int,
) -> List(#(Int, #(Float, Float))) {
  list.range(0, starting_outpost_count * list.length(spawn_points))
  |> list.map(fn(_) { spawn_points })
  |> list.concat
  |> list.shuffle
  |> assign_outposts_inner_loop(outposts)
}

fn assign_outposts_inner_loop(
  spawn_points_assignment_list: List(#(Int, #(Float, Float))),
  outposts: List(#(Float, Float)),
) -> List(#(Int, #(Float, Float))) {
  case spawn_points_assignment_list {
    [] ->
      outposts
      |> list.map(fn(pst) {
        let #(x, y) = pst
        #(-1, x, y)
      })
    [current_spawn_point, ..rest] -> {
      let closest_points = list.sort(outposts, fn(first, second) { todo })
    }
  }
}
