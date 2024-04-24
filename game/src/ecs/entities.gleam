import gleam/bool.{guard}
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/list
import idgen

pub fn new_entity_id() -> String {
  idgen.new(64)
}

pub opaque type Player {
  Player(id: String)
}

pub fn new_player(id: String) -> Player {
  Player(id)
}

pub fn player_ids_match(left: Player, right: Player) -> Bool {
  left.id == right.id
}

pub fn list_owned_outposts(world: World, player: Player) -> List(Outpost) {
  list.filter(world.outposts, fn(outpost) {
    case outpost.owner {
      OutpostPlayerOwned(outpost_player_id) -> outpost_player_id == player.id
      _ -> False
    }
  })
}

pub fn list_owned_ships(world: World, player: Player) -> List(Ship) {
  list.filter(world.ships, fn(ship) {
    case ship.owner {
      ShipPlayerOwned(ship_player_id) -> ship_player_id == player.id
      _ -> False
    }
  })
}

pub fn list_owned_specialists(world: World, player: Player) -> List(Specialist) {
  list.filter(world.specialists, fn(spec) {
    case spec.owner {
      SpecPlayerOwned(spec_player_id) -> spec_player_id == player.id
      _ -> False
    }
  })
}

pub opaque type Outpost {
  Outpost(
    id: String,
    outpost_type: OutpostType,
    location: #(Float, Float),
    owner: OutpostOwnership,
    units: Int,
  )
}

pub fn outpost_ids_match(left: Outpost, right: Outpost) -> Bool {
  left.id == right.id
}

pub fn new_factory(
  id: String,
  location: #(Float, Float),
  owner: Option(String),
) -> Outpost {
  let ownership = case owner {
    Some(id) -> OutpostPlayerOwned(id)
    None -> OutpostUnowned
  }

  Outpost(
    id: id,
    outpost_type: Factory,
    location: location,
    owner: ownership,
    units: 0,
  )
}

pub fn new_generator(
  id: String,
  location: #(Float, Float),
  owner: Option(String),
) -> Outpost {
  let ownership = case owner {
    Some(id) -> OutpostPlayerOwned(id)
    None -> OutpostUnowned
  }

  Outpost(
    id: id,
    outpost_type: Generator,
    location: location,
    owner: ownership,
    units: 0,
  )
}

pub fn new_unknown_outpost(
  id: String,
  location: #(Float, Float),
  owner: Option(String),
) -> Outpost {
  let ownership = case owner {
    Some(id) -> OutpostPlayerOwned(id)
    None -> OutpostUnowned
  }

  Outpost(
    id: id,
    outpost_type: Unknown,
    location: location,
    owner: ownership,
    units: 0,
  )
}

pub fn to_mine(outpost: Outpost, units_required: Int) -> Result(Outpost, Nil) {
  use <- guard(outpost.units < units_required, Error(Nil))

  case outpost.outpost_type {
    Factory | Generator ->
      Ok(
        Outpost(
          ..outpost,
          outpost_type: Mine,
          units: outpost.units
          - units_required,
        ),
      )
    _ -> Error(Nil)
  }
}

pub fn to_wreck(outpost: Outpost) -> Outpost {
  Outpost(..outpost, outpost_type: Wreck)
}

pub type OutpostType {
  Factory
  Generator
  Wreck
  Mine
  Unknown
}

pub fn is_factory(outpost: Outpost) -> Bool {
  case outpost.outpost_type {
    Factory -> True
    _ -> False
  }
}

pub fn is_generator(outpost: Outpost) -> Bool {
  case outpost.outpost_type {
    Generator -> True
    _ -> False
  }
}

pub fn is_wreck(outpost: Outpost) -> Bool {
  case outpost.outpost_type {
    Wreck -> True
    _ -> False
  }
}

pub fn is_mine(outpost: Outpost) -> Bool {
  case outpost.outpost_type {
    Mine -> True
    _ -> False
  }
}

pub fn is_outpost_type_unknown(outpost: Outpost) -> Bool {
  case outpost.outpost_type {
    Unknown -> True
    _ -> False
  }
}

pub type OutpostOwnership {
  OutpostPlayerOwned(player_id: String)
  OutpostUnowned
}

pub fn is_outpost_owned(outpost: Outpost) -> Bool {
  case outpost.owner {
    OutpostPlayerOwned(_) -> True
    _ -> False
  }
}

pub fn is_outpost_owned_by_player(outpost: Outpost, player: Player) -> Bool {
  case outpost.owner {
    OutpostPlayerOwned(outpost_player_id) -> outpost_player_id == player.id
    _ -> False
  }
}

pub fn is_outpost_owned_by_player_id(
  outpost: Outpost,
  player_id: String,
) -> Bool {
  case outpost.owner {
    OutpostPlayerOwned(outpost_player_id) -> outpost_player_id == player_id
    _ -> False
  }
}

pub fn get_outpost_owner(world: World, outpost: Outpost) -> Result(Player, Nil) {
  case outpost.owner {
    OutpostPlayerOwned(player_id) ->
      list.find(world.players, fn(player) { player.id == player_id })
    OutpostUnowned -> Error(Nil)
  }
}

pub fn set_outpost_player_owned(outpost: Outpost, player: Player) -> Outpost {
  Outpost(..outpost, owner: OutpostPlayerOwned(player.id))
}

pub fn set_outpost_unowned(outpost: Outpost) -> Outpost {
  Outpost(..outpost, owner: OutpostUnowned)
}

pub fn outpost_list_targeting_ships(
  world: World,
  outpost: Outpost,
) -> List(Ship) {
  list.filter(world.ships, ship_targeting_outpost(_, outpost))
}

pub opaque type Ship {
  Ship(
    id: String,
    location: #(Float, Float),
    target: ShipTarget,
    owner: ShipOwner,
    units: Int,
  )
}

pub fn ship_ids_match(left: Ship, right: Ship) -> Bool {
  left.id == right.id
}

pub fn new_ship(
  id: String,
  location: #(Float, Float),
  target: ShipTarget,
  owner: Option(String),
  units: Int,
) -> Ship {
  let owner = case owner {
    Some(owner_id) -> ShipPlayerOwned(owner_id)
    None -> ShipUnowned
  }

  Ship(id, location, target, owner, units)
}

pub type ShipTarget {
  ShipOutpostTarget(outpost_id: String)
  ShipShipTarget(ship_id: String)
  UnknownTarget(heading: Float)
}

pub fn new_outpost_target(outpost: Outpost) -> ShipTarget {
  ShipOutpostTarget(outpost.id)
}

pub fn new_ship_target(ship: Ship) -> ShipTarget {
  ShipShipTarget(ship.id)
}

pub fn new_ship_unknown_target(heading: Float) -> ShipTarget {
  UnknownTarget(heading)
}

pub fn ship_target_outpost(ship: Ship) -> Bool {
  case ship.target {
    ShipOutpostTarget(_) -> True
    _ -> False
  }
}

pub fn ship_targeting_outpost(ship: Ship, outpost: Outpost) -> Bool {
  case ship.target {
    ShipOutpostTarget(target_id) if target_id == outpost.id -> True
    _ -> False
  }
}

pub fn ship_target_ship(ship: Ship) -> Bool {
  case ship.target {
    ShipShipTarget(_) -> True
    _ -> False
  }
}

pub fn ship_targeting_ship(ship: Ship, target: Ship) -> Bool {
  case ship.target {
    ShipShipTarget(target_id) if target_id == target.id -> True
    _ -> False
  }
}

pub fn ship_target_unknown(ship: Ship) -> Bool {
  case ship.target {
    UnknownTarget(_) -> True
    _ -> False
  }
}

pub fn ship_get_targeted_outpost(
  world: World,
  ship: Ship,
) -> Result(Outpost, Nil) {
  case ship.target {
    ShipOutpostTarget(outpost_id) ->
      list.find(world.outposts, fn(outpost) { outpost.id == outpost_id })
    _ -> Error(Nil)
  }
}

pub fn ship_get_targeted_ship(world: World, ship: Ship) -> Result(Ship, Nil) {
  case ship.target {
    ShipShipTarget(ship_id) ->
      list.find(world.ships, fn(ship) { ship.id == ship_id })
    _ -> Error(Nil)
  }
}

pub fn ship_get_unknown_target_heading(
  _world: World,
  ship: Ship,
) -> Result(Float, Nil) {
  case ship.target {
    UnknownTarget(heading) -> Ok(heading)
    _ -> Error(Nil)
  }
}

pub fn ship_retarget_to_outpost(ship: Ship, outpost: Outpost) -> Ship {
  Ship(..ship, target: ShipOutpostTarget(outpost.id))
}

pub fn ship_retarget_to_ship(ship: Ship, target_ship: Ship) -> Ship {
  Ship(..ship, target: ShipShipTarget(target_ship.id))
}

pub type ShipOwner {
  ShipPlayerOwned(player_id: String)
  ShipUnowned
}

pub fn ship_is_player_owned(ship: Ship) -> Bool {
  case ship.owner {
    ShipPlayerOwned(_) -> True
    _ -> False
  }
}

pub fn ship_is_owned_by_player(ship: Ship, player: Player) -> Bool {
  case ship.owner {
    ShipPlayerOwned(player_id) if player_id == player.id -> True
    _ -> False
  }
}

pub fn ship_is_unowned(ship: Ship) -> Bool {
  case ship.owner {
    ShipUnowned -> True
    _ -> False
  }
}

pub fn ship_set_unowned(ship: Ship) -> Ship {
  Ship(..ship, owner: ShipUnowned)
}

pub fn ship_set_owner_player(ship: Ship, player: Player) -> Ship {
  Ship(..ship, owner: ShipPlayerOwned(player.id))
}

pub fn ship_get_owning_player(world: World, ship: Ship) -> Result(Player, Nil) {
  case ship.owner {
    ShipPlayerOwned(owner_id) ->
      list.find(world.players, fn(player) { player.id == owner_id })
    _ -> Error(Nil)
  }
}

pub fn ship_get_targeting_ships(world: World, ship: Ship) -> List(Ship) {
  list.filter(world.ships, ship_targeting_ship(_, ship))
}

pub opaque type Specialist {
  Specialist(
    id: String,
    specialist_type: SpecialistType,
    location: SpecialistLocation,
    owner: SpecialistOwnership,
  )
}

pub fn specialist_ids_match(left: Specialist, right: Specialist) -> Bool {
  left.id == right.id
}

pub fn new_specialist(
  id: String,
  specialist_type: SpecialistType,
  specialist_location: SpecialistLocation,
  owner: Option(String),
) -> Specialist {
  let owner = case owner {
    Some(owner_id) -> SpecPlayerOwned(owner_id)
    None -> SpecUnowned
  }

  Specialist(id, specialist_type, specialist_location, owner)
}

pub type SpecialistType {
  Queen
  Princess
  Pirate
  Helmsman
}

pub fn spec_set_type(
  specialist: Specialist,
  spec_type: SpecialistType,
) -> Specialist {
  Specialist(..specialist, specialist_type: spec_type)
}

pub type SpecialistLocation {
  SpecOutpostLocation(outpost_id: String)
  SpecShipLocation(ship_id: String)
  SpecUnknownLocation
}

pub fn spec_set_location(
  spec: Specialist,
  new_location: SpecialistLocation,
) -> Specialist {
  Specialist(..spec, location: new_location)
}

pub fn spec_new_outpost_location(outpost: Outpost) -> SpecialistLocation {
  SpecOutpostLocation(outpost.id)
}

pub fn spec_new_ship_location(ship: Ship) -> SpecialistLocation {
  SpecShipLocation(ship.id)
}

pub fn spec_new_unknown_location() -> SpecialistLocation {
  SpecUnknownLocation
}

pub type SpecialistOwnership {
  SpecPlayerOwned(player_id: String)
  SpecUnowned
}

pub fn spec_set_ownership(
  spec: Specialist,
  owner: SpecialistOwnership,
) -> Specialist {
  Specialist(..spec, owner: owner)
}

pub fn spec_new_player_owner(player: Player) -> SpecialistOwnership {
  SpecPlayerOwned(player.id)
}

pub fn spec_new_unowned_owner() -> SpecialistOwnership {
  SpecUnowned
}

pub opaque type GameMode {
  Standard
  Quickplay
}

pub opaque type World {
  World(
    world_type: WorldType,
    current_tick: Int,
    size: Int,
    players: List(Player),
    outposts: List(Outpost),
    ships: List(Ship),
    specialists: List(Specialist),
    config: WorldConfig,
  )
}

pub fn new_server_world(config: WorldConfig) -> World {
  World(
    world_type: ServerWorld,
    current_tick: 0,
    size: 0,
    players: [],
    outposts: [],
    ships: [],
    specialists: [],
    config: config,
  )
}

pub fn new_client_world(config: WorldConfig, player: Player) -> World {
  World(
    world_type: ClientWorld(player.id),
    current_tick: 0,
    size: 0,
    players: [],
    outposts: [],
    ships: [],
    specialists: [],
    config: config,
  )
}

fn upsert_list_multiple(
  input_list: List(a),
  items items: List(a),
  matcher matcher: fn(a, a) -> Bool,
) -> List(a) {
  let #(remaining, list) =
    list.map_fold(input_list, items, fn(remaining_items, curr) {
      use <- guard(list.is_empty(remaining_items), #([], curr))

      let matches_remaining_item = list.find(remaining_items, matcher(curr, _))
      use <- guard(result.is_error(matches_remaining_item), #(
        remaining_items,
        curr,
      ))

      let assert Ok(item) = matches_remaining_item
      let filtered_remaining_items =
        list.filter(remaining_items, fn(item) { !matcher(item, curr) })

      #(filtered_remaining_items, item)
    })

  list.concat([remaining, list])
}

fn delete_list_multiple(
  input_list: List(a),
  to_delete to_delete: List(a),
  matcher matcher: fn(a, a) -> Bool,
) -> List(a) {
  list.filter(input_list, fn(curr) { list.any(to_delete, matcher(_, curr)) })
}

pub fn world_set_tick(world: World, new_tick: Int) -> World {
  World(..world, current_tick: new_tick)
}

pub fn world_set_size(world: World, size: Int) -> World {
  World(..world, size: size)
}

pub fn world_set_players_list(world: World, new_players: List(Player)) -> World {
  World(..world, players: new_players)
}

pub fn world_set_player(world: World, new_player: Player) -> World {
  let updated_players =
    upsert_list_multiple(world.players, [new_player], player_ids_match)

  World(..world, players: updated_players)
}

pub fn world_set_players_many(world: World, new_players: List(Player)) -> World {
  let updated_players =
    upsert_list_multiple(world.players, new_players, player_ids_match)

  World(..world, players: updated_players)
}

pub fn world_delete_player(world: World, player: Player) -> World {
  let updated_players =
    delete_list_multiple(world.players, [player], player_ids_match)

  World(..world, players: updated_players)
}

pub fn world_delete_players_many(world: World, players: List(Player)) -> World {
  let updated_players =
    delete_list_multiple(world.players, players, player_ids_match)

  World(..world, players: updated_players)
}

pub fn world_set_outposts_list(
  world: World,
  new_outposts: List(Outpost),
) -> World {
  World(..world, outposts: new_outposts)
}

pub fn world_set_outpost(world: World, outpost: Outpost) -> World {
  let updated_outposts =
    delete_list_multiple(world.outposts, [outpost], outpost_ids_match)

  World(..world, outposts: updated_outposts)
}

pub fn world_set_outposts_many(
  world: World,
  new_outposts: List(Outpost),
) -> World {
  let updated_outposts =
    delete_list_multiple(world.outposts, new_outposts, outpost_ids_match)

  World(..world, outposts: updated_outposts)
}

pub fn world_delete_outpost(world: World, outpost: Outpost) -> World {
  let updated_outposts =
    delete_list_multiple(world.outposts, [outpost], outpost_ids_match)

  World(..world, outposts: updated_outposts)
}

pub fn world_delete_outposts_many(
  world: World,
  to_delete: List(Outpost),
) -> World {
  let updated_outposts =
    delete_list_multiple(world.outposts, to_delete, outpost_ids_match)

  World(..world, outposts: updated_outposts)
}

pub fn world_set_ships_list(world: World, new_ships: List(Ship)) -> World {
  World(..world, ships: new_ships)
}

pub fn world_set_ship(world: World, ship: Ship) -> World {
  let updated_ships = delete_list_multiple(world.ships, [ship], ship_ids_match)

  World(..world, ships: updated_ships)
}

pub fn world_set_ships_many(world: World, new_ships: List(Ship)) -> World {
  let updated_ships =
    delete_list_multiple(world.ships, new_ships, ship_ids_match)

  World(..world, ships: updated_ships)
}

pub fn world_delete_ship(world: World, ship: Ship) -> World {
  let updated_ships = delete_list_multiple(world.ships, [ship], ship_ids_match)

  World(..world, ships: updated_ships)
}

pub fn world_delete_ships_many(world: World, to_delete: List(Ship)) -> World {
  let updated_ships =
    delete_list_multiple(world.ships, to_delete, ship_ids_match)

  World(..world, ships: updated_ships)
}

pub fn world_set_specialists_list(
  world: World,
  new_specialists: List(Specialist),
) -> World {
  World(..world, specialists: new_specialists)
}

pub fn world_set_specialist(world: World, specialist: Specialist) -> World {
  let updated_specialists =
    delete_list_multiple(world.specialists, [specialist], specialist_ids_match)

  World(..world, specialists: updated_specialists)
}

pub fn world_set_specialists_many(
  world: World,
  new_specialists: List(Specialist),
) -> World {
  let updated_specialists =
    delete_list_multiple(
      world.specialists,
      new_specialists,
      specialist_ids_match,
    )

  World(..world, specialists: updated_specialists)
}

pub fn world_delete_specialist(world: World, specialist: Specialist) -> World {
  let updated_specialists =
    delete_list_multiple(world.specialists, [specialist], specialist_ids_match)

  World(..world, specialists: updated_specialists)
}

pub fn world_delete_specialists_many(
  world: World,
  to_delete: List(Specialist),
) -> World {
  let updated_specialists =
    delete_list_multiple(world.specialists, to_delete, specialist_ids_match)

  World(..world, specialists: updated_specialists)
}

pub opaque type WorldConfig {
  WorldConfig(gamemode: GameMode)
}

pub fn new_standard_config() -> WorldConfig {
  WorldConfig(gamemode: Standard)
}

pub fn new_quickplay_config() -> WorldConfig {
  WorldConfig(gamemode: Quickplay)
}

pub type WorldType {
  ServerWorld
  ClientWorld(for_player_id: String)
}

pub fn world_is_server_world(world: World) -> Bool {
  case world.world_type {
    ServerWorld -> True
    _ -> False
  }
}

pub fn world_is_client_world(world: World) -> Bool {
  case world.world_type {
    ClientWorld(_) -> True
    _ -> False
  }
}
