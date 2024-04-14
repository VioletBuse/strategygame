import ecs/entities/ships.{type ShipTarget}

pub type PlayerAction {
  SendShip(
    by: Int,
    from: Int,
    to: ShipTarget,
    stationed_units: Int,
    specialists: List(Int),
  )
}
