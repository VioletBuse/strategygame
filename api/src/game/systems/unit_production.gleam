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

pub fn create_unit_production_system() -> UnitProductionSystem {
  let assert Ok(actor) = actor.start(UnitProductionSystemState, handle_message)

  UnitProductionSystem(actor)
}

pub fn run_tick(ups: UnitProductionSystem) -> Result(Nil, Nil) {
  process.call(ups.actor, RunTick, 10)
}

pub fn shutdown(ups: UnitProductionSystem) -> Nil {
  process.send(ups.actor, Shutdown)
}

pub fn get_pid(ups: UnitProductionSystem) -> Result(process.Pid, Nil) {
  process.call(ups.actor, GetPid, 10)
}

pub fn link_process(ups: UnitProductionSystem) -> Result(Nil, Nil) {
  get_pid(ups)
  |> pid.link_actor
}
