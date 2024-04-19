import gleam/list
import ecs/world.{type World}
import ecs/entities/outposts
import ecs/entities/players
import ecs/entities/specialists

pub fn get(world: World, oid: Int) -> Result(outposts.Outpost, Nil) {
  case list.find(world.outposts, fn(outpost) { outpost.id == oid }) {
    Ok(outpost) -> Ok(outpost)
    _ -> Error(Nil)
  }
}

pub fn owner(
  outpost: outposts.Outpost,
  world: World,
) -> Result(players.Player, Nil) {
  case outpost.ownership {
    outposts.PlayerOwned(pid) ->
      case list.find(world.players, fn(player) { player.id == pid }) {
        Ok(player) -> Ok(player)
        _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

pub fn get_type(outpost: outposts.Outpost) -> outposts.OutpostType {
  outpost.outpost_type
}

pub fn get_location(outpost: outposts.Outpost) -> #(Float, Float) {
  let outposts.OutpostLocation(x, y) = outpost.location
  #(x, y)
}

pub fn get_specialists(
  world: World,
  outpost: outposts.Outpost,
) -> List(specialists.Specialist) {
  list.filter(world.specialists, fn(specialist) {
    case specialist.location {
      specialists.OutpostLocation(oid) -> oid == outpost.id
      _ -> False
    }
  })
}

pub fn update_outpost(world: World, updated_outpost: outposts.Outpost) -> World {
  let updated_outposts =
    list.map(world.outposts, fn(outpost) {
      case outpost {
        curr_outpost if curr_outpost.id == updated_outpost.id -> updated_outpost
        curr_outpost -> curr_outpost
      }
    })

  // world.World(..world, outposts: updated_outposts)

  case world {
    world.ServerWorld(_, _, _, _, _, _, _) as server ->
      world.ServerWorld(..server, outposts: updated_outposts)
    world.ClientWorld(_, _, _, _, _, _, _, _) as client ->
      world.world.ClientWorld(..client, outposts: updated_outposts)
  }
}

pub fn merge_list(world: World, outpost_list: List(outposts.Outpost)) -> World {
  let updated_outposts =
    list.map(world.outposts, fn(outpost) {
      case
        list.find(outpost_list, fn(new_outpost) { new_outpost.id == outpost.id })
      {
        Ok(new_outpost) -> new_outpost
        _ -> outpost
      }
    })

  world.World(..world, outposts: updated_outposts)
}
