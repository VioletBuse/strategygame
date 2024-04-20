import gleam/list
import ecs/world.{type World}
import ecs/entities/outposts.{type Outpost}
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

pub fn add_outpost(world: World, outpost: Outpost) -> World {
  todo
}

pub fn update_outpost(world: World, outpost: Outpost) -> World {
  todo
}

pub fn delete_outpost(world: World, outpost: Outpost) -> World {
  todo
}

pub fn add_outposts(world: World, outposts: List(Outpost)) -> World {
  todo
}

pub fn update_outposts(world: World, outposts: List(Outpost)) -> World {
  todo
}

pub fn delete_outposts(world: World, outposts: List(Outpost)) -> World {
  todo
}
