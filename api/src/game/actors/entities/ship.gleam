import gleam/erlang/process
import gleam/otp/actor

pub type Ship {
    Ship(actor: process.Subject(ShipMessage))
}

pub type ShipMessage {
    Initialize(spawn_tick: Int)
    AdvanceTick
    Shutdown
}

pub type ShipState {
    ShipState(spawn_tick: Int)
}

fn handle_message(message: ShipMessage, state: ShipState) -> actor.Next(ShipMessage, ShipState) {
    case state {
        ShipState(_spawn_tick) -> case message {
            Shutdown -> actor.Stop(process.Normal)
            _ -> actor.continue(state)
        }
    }
}

pub fn create_ship(spawn_tick: Int) -> Result(Ship, Nil) {
    case actor.start(ShipState(spawn_tick), handle_message) {
        Ok(reference) -> Ok(Ship(reference))
        Error(_) -> Error(Nil)
    }
}
