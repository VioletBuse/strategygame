import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import utils/pid

pub type OutpostManager {
  OutpostManager(actor: Subject(OutpostManagerMessage))
}

pub type OutpostManagerMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
}

pub type OutpostManagerState {
  OutpostManagerState
}

fn handle_message(
  message: OutpostManagerMessage,
  state: OutpostManagerState,
) -> actor.Next(OutpostManagerMessage, OutpostManagerState) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    GetPid(client) -> {
      pid.send_pid(client)
      actor.continue(state)
    }
  }
}

pub fn create_outpost_manager() -> OutpostManager {
  let assert Ok(actor) = actor.start(OutpostManagerState, handle_message)

  OutpostManager(actor)
}

pub fn shutdown(manager: OutpostManager) -> Nil {
  process.send(manager.actor, Shutdown)
}

pub fn get_pid(manager: OutpostManager) -> Result(process.Pid, Nil) {
  process.call(manager.actor, GetPid, 10)
}

pub fn link_process(manager: OutpostManager) -> Result(Nil, Nil) {
  get_pid(manager)
  |> pid.link_actor
}
