import gleam/otp/actor
import gleam/erlang/process.{type Subject}

pub type Ship {
  Ship(actor: Subject(ShipMessage))
}

pub type ShipMessage {
  Shutdown
}

pub type ShipState {
  ShipState
}

fn handle_message(
  message: ShipMessage,
  state: ShipState,
) -> actor.Next(ShipMessage, ShipState) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
  }
}

pub fn create_ship() -> Ship {
  let assert Ok(actor) = actor.start(ShipState, handle_message)

  Ship(actor)
}
