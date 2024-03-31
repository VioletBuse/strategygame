import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import gleam/dynamic

pub type Ship {
  Ship(actor: Subject(ShipMessage))
}

pub type ShipMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
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
    GetPid(client) -> {
      let pid = case process.pid_from_dynamic(dynamic.from(process.self())) {
        Ok(pid) -> Ok(pid)
        Error(_) -> Error(Nil)
      }

      process.send(client, pid)
      actor.continue(state)
    }
  }
}

pub fn create_ship() -> Ship {
  let assert Ok(actor) = actor.start(ShipState, handle_message)

  Ship(actor)
}
