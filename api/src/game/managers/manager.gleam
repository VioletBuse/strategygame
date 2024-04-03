import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import utils/pid

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
      pid.send_pid(client)
      actor.continue(state)
    }
  }
}

pub fn create_game_manager() -> GameManager {
  let assert Ok(actor) = actor.start(GameManagerState, handle_message)
  GameManager(actor)
}

pub fn shutdown(manager: GameManager) -> Nil {
  process.send(manager.actor, Shutdown)
}

pub fn get_pid(manager: GameManager) -> Result(process.Pid, Nil) {
  process.call(manager.actor, GetPid, 10)
}

pub fn link_process(manager: GameManager) -> Result(Nil, Nil) {
  get_pid(manager)
  |> pid.link_actor
}
