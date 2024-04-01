import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import utils/pid

pub type UnitProductionSystem {
  UnitProductionSystem(actor: Subject(UnitProductionSystemMessage))
}

pub type UnitProductionSystemMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
  RunTick(reply_with: Subject(Result(Nil, Nil)))
}

pub type UnitProductionSystemState {
  UnitProductionSystemState
}

fn handle_message(
  message: UnitProductionSystemMessage,
  state: UnitProductionSystemState,
) -> actor.Next(UnitProductionSystemMessage, UnitProductionSystemState) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    GetPid(client) -> {
      pid.send_pid(client)
      actor.continue(state)
    }
    RunTick(client) -> {
      process.send(client, Ok(Nil))
      actor.continue(state)
    }
  }
}
