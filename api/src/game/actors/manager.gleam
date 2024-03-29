import gleam/otp/actor
import gleam/erlang/process

pub type GameManager {
    GameManager(actor: process.Subject(GameManagerMessage))
}

pub type GameManagerMessage {
    Shutdown
}

pub type GameManagerState {
    GameManagerState
}

fn handle_message(message: GameManagerMessage, _state: GameManagerState) -> actor.Next(GameManagerMessage, GameManagerState) {
    case message {
        Shutdown -> actor.Stop(process.Normal)
    }
}

pub fn create_game_manager() -> Result(GameManager, Nil) {
    case actor.start(GameManagerState, handle_message) {
        Ok(reference) -> Ok(GameManager(reference))
        Error(_) -> Error(Nil)
    }
}

pub fn shutdown_game_manager(manager: GameManager) -> Nil {
    process.send(manager.actor, Shutdown)
}


