import gleam/list
import ecs/world.{type World}
import ecs/entities/outposts

pub fn handler(world: World) -> Result(World, Nil) {
  let updated_outposts =
    list.map(world.outposts, fn(outpost) -> outposts.Outpost {
      case outpost {
        outposts.Outpost(
          _,
          outposts.Factory(production_offset),
          _,
          _,
          stationed_units,
        ) ->
          outposts.Outpost(
            ..outpost,
            outpost_type: outposts.Factory(production_offset: 0),
            stationed_units: stationed_units
            + 20
            + production_offset,
          )
        curr_outpost -> curr_outpost
      }
    })

  Ok(world.World(..world, outposts: updated_outposts))
}
