import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import gleam/dynamic

pub type WorldManager {
  WorldManager(actor: Subject(WorldManagerMessage))
}

pub type WorldManagerMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
  GetSize(reply_with: Subject(Int))
}

pub type WorldManagerState {
  WorldManagerState(size: Int)
}

fn handle_message(
  message: WorldManagerMessage,
  state: WorldManagerState,
) -> actor.Next(WorldManagerMessage, WorldManagerState) {
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
    GetSize(client) -> {
      process.send(client, state.size)
      actor.continue(state)
    }
  }
}

pub fn create_world_manager(size size: Int) -> WorldManager {
  let assert Ok(actor) =
    actor.start(WorldManagerState(size: size), handle_message)

  WorldManager(actor)
}

pub fn shutdown(manager: WorldManager) -> Nil {
  process.send(manager.actor, Shutdown)
}

pub fn get_pid(manager: WorldManager) -> Result(process.Pid, Nil) {
  process.call(manager.actor, GetPid, 10)
}

pub fn link_process(manager: WorldManager) -> Result(Nil, Nil) {
  case get_pid(manager) {
    Ok(pid) ->
      case process.link(pid) {
        True -> Ok(Nil)
        False -> Error(Nil)
      }
    Error(_) -> Error(Nil)
  }
}

pub fn get_size(manager: WorldManager) -> Int {
  process.call(manager.actor, GetSize, 10)
}
