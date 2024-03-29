import gleam/erlang/process
import gleam/otp/actor

pub type Ship {
    Ship(actor: process.Subject(ShipMessage))
}

pub type ShipMessage {
    AdvanceTick
    Shutdown
}

pub type ShipState {
    ShipState(tick: Int, spawn_tick: Int)
}

fn handle_message(message: ShipMessage, state: ShipState) -> actor.Next(ShipMessage, ShipState) {
    case state {
        ShipState(current_tick, _spawn_tick) -> case message {
            Shutdown -> actor.Stop(process.Normal)
            AdvanceTick -> actor.continue(ShipState(..state, tick: current_tick + 1))
        }
    }
}

pub fn create_ship(spawn_tick: Int) -> Result(Ship, Nil) {
    case actor.start(ShipState(0, spawn_tick), handle_message) {
        Ok(reference) -> Ok(Ship(reference))
        Error(_) -> Error(Nil)
    }
}

pub fn advance_tick(ship: Ship) -> Nil {
    process.send(ship.actor, AdvanceTick)
}

pub fn shutdown_ship(ship: Ship) -> Nil {
    process.send(ship.actor, Shutdown)
}
