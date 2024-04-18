import ecs/entities/ships.{type ShipTarget}

pub type PlayerAction {
  SendShip(
    by: Int,
    from: Int,
    to: ShipTarget,
    units: Int,
    specialists: List(Int),
  )
  RerouteShip(by: Int, ship: Int, to: ShipTarget)
}
