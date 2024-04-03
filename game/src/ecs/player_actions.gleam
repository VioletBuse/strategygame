import ecs/entities/ships.{type ShipSource, type ShipTarget}

pub type PlayerActions {
  SendShip(tick: Int, from: ShipSource, to: ShipTarget)
}
