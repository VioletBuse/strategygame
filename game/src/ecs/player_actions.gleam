import ecs/entities/ships.{type ShipTarget}

pub type PlayerActions {
  SendShip(tick: Int, to: ShipTarget)
}
