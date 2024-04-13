import gleam/int
import gleam/list
import gleam/result
import ecs/entities/outposts.{
  Factory, Generator, Outpost, OutpostLocation, Player as PlayerOwned, Unowned,
}
import ecs/entities/players.{Player}
import ecs/entities/specialists.{
  OutpostLocation as SpecialistOutpostLocation, Player as PlayerOwnedSpecialist,
  Queen, Specialist,
}
import ecs/world as ecs_world
import worldgen/world
import worldgen/grid_utils

pub type WorldgenPreset {
  Standard(player_ids: List(Int))
}

pub fn create(preset: WorldgenPreset) -> Result(ecs_world.World, Nil) {
  let #(
    player_ids,
    world_size,
    starting_gen,
    starting_fac,
    unclaimed_outposts_per_person,
    gen_fac_ratio,
    starting_stationed_units,
  ) = case preset {
    Standard(player_ids) -> #(player_ids, 300, 2, 3, 6, 0.4, 20)
  }

  let players = list.map(player_ids, fn(id) { Player(id) })
  let ships = []

  let outposts = {
    use generated_outposts <- result.try(world.generate_world(
      list.length(players),
      starting_gen,
      starting_fac,
      unclaimed_outposts_per_person,
      gen_fac_ratio,
    ))

    let mapped = {
      use single_outpost <- list.map(
        generated_outposts
        |> grid_utils.scale_exported_grid_to_size_with_ids(world_size),
      )

      let #(outpost_id, generated_outpost_type, player_id, queen_spawn, x, y) = case
        single_outpost
      {
        #(world.UnownedOutpost(id, outpost_type), x, y) -> #(
          id,
          outpost_type,
          -1,
          False,
          x,
          y,
        )
        #(
          world.OwnedOutpost(outpost_id, outpost_type, player_id, queen_spawn),
          x,
          y,
        ) -> #(outpost_id, outpost_type, player_id, queen_spawn, x, y)
      }

      let outpost_type = case generated_outpost_type {
        world.GeneratedFactory -> Factory
        world.GeneratedGenerator -> Generator
      }

      let outpost_ownership_result = case player_id {
        -1 -> Ok(Unowned)
        p_idx ->
          case list.at(players, p_idx - 1) {
            Ok(Player(pid)) -> Ok(PlayerOwned(pid))
            Error(_) -> Error(Nil)
          }
      }

      let stationed_units = case player_id {
        -1 -> 0
        _ -> starting_stationed_units
      }

      use outpost_ownership <- result.try(outpost_ownership_result)

      Ok(#(
        Outpost(
          outpost_id,
          outpost_type,
          OutpostLocation(x, y),
          outpost_ownership,
          stationed_units,
        ),
        queen_spawn,
      ))
    }

    Ok(
      mapped
      |> result.values,
    )
  }

  use generated <- result.try(outposts)

  let outposts = list.map(generated, fn(generated) { generated.0 })

  let specialists =
    list.filter(generated, fn(v) { v.1 })
    |> list.map(fn(v) {
      let assert #(Outpost(oid, _, _, PlayerOwned(pid), _), _) = v
      Specialist(
        int.random(1_000_000_000),
        Queen,
        SpecialistOutpostLocation(oid),
        PlayerOwnedSpecialist(pid),
      )
    })

  Ok(ecs_world.World(
    outposts: outposts,
    ships: ships,
    players: players,
    specialists: specialists,
  ))
}
