import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import utils/pid

pub type Player {
  Player(actor: Subject(PlayerMessage))
}

pub type PlayerMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
}

pub type PlayerState {
  PlayerState
}

fn handle_message(
  message: PlayerMessage,
  state: PlayerState,
) -> actor.Next(PlayerMessage, PlayerState) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    GetPid(client) -> {
      pid.send_pid(client)
      actor.continue(state)
    }
  }
}

pub fn create_player() -> Player {
  let assert Ok(actor) = actor.start(PlayerState, handle_message)

  Player(actor)
}

pub fn get_pid(player: Player) -> Result(process.Pid, Nil) {
  process.call(player.actor, GetPid, 10)
}

pub fn link_process(player: Player) -> Result(Nil, Nil) {
  get_pid(player)
  |> pid.link_actor
}
