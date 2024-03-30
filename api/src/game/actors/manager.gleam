import gleam/otp/actor
import gleam/erlang/process

pub type GameManager {
  GameManager(actor: process.Subject(GameManagerMessage))
}

pub type GameManagerInitError {
  UnknownError
}

pub type GameManagerMessage {
  Shutdown
}

pub type GameManagerState {
  GameManagerState
}

fn handle_message(
  message: GameManagerMessage,
  state: GameManagerState,
) -> actor.Next(GameManagerMessage, GameManagerState) {
  case state {
    GameManagerState ->
      case message {
        Shutdown -> actor.Stop(process.Normal)
      }
  }
}

pub fn create_game_manager() -> Result(GameManager, GameManagerInitError) {
  case actor.start(GameManagerState, handle_message) {
    Ok(reference) -> Ok(GameManager(reference))
    Error(_) -> Error(UnknownError)
  }
}

pub fn shutdown_game_manager(manager: GameManager) -> Nil {
  process.send(manager.actor, Shutdown)
}
