import ecs/entities/ships.{type ShipTarget}

pub type PlayerAction {
  SendShip(tick: Int, to: ShipTarget)
}
