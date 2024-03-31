import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import gleam/dynamic

pub type GameManager {
  GameManager(actor: process.Subject(GameManagerMessage))
}

pub type GameManagerInitError {
  UnknownError
}

pub type GameManagerMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
}

pub type GameManagerState {
  GameManagerState
}

fn handle_message(
  message: GameManagerMessage,
  state: GameManagerState,
) -> actor.Next(GameManagerMessage, GameManagerState) {
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

pub fn create_game_manager() -> Result(GameManager, GameManagerInitError) {
  case actor.start(GameManagerState, handle_message) {
    Ok(reference) -> Ok(GameManager(reference))
    Error(_) -> Error(UnknownError)
  }
}

pub fn shutdown(manager: GameManager) -> Nil {
  process.send(manager.actor, Shutdown)
}

pub fn get_pid(manager: GameManager) -> Result(process.Pid, Nil) {
  process.call(manager.actor, GetPid, 10)
}

pub fn link_process(manager: GameManager) -> Result(Nil, Nil) {
  case get_pid(manager) {
    Ok(pid) ->
      case process.link(pid) {
        True -> Ok(Nil)
        False -> Error(Nil)
      }
    Error(_) -> Error(Nil)
  }
}
