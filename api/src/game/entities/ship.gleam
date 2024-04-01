import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import utils/pid

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
      pid.send_pid(client)
      actor.continue(state)
    }
  }
}

pub fn create_ship() -> Ship {
  let assert Ok(actor) = actor.start(ShipState, handle_message)

  Ship(actor)
}

pub fn get_pid(ship: Ship) -> Result(process.Pid, Nil) {
  process.call(ship.actor, GetPid, 10)
}

pub fn link_process(ship: Ship) -> Result(Nil, Nil) {
  get_pid(ship)
  |> pid.link_actor
}
