import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import gleam/dynamic

pub type Ticker {
  Ticker(actor: Subject(TickerMessage))
}

pub type TickerMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
  TickForward(reply_with: Subject(Result(TickSuccess, TickFailure)))
}

pub type TickSuccess {
  TickSuccess
}

pub type TickFailure {
  UnknownError
}

pub type TickerState {
  TickerState
}

fn handle_message(
  message: TickerMessage,
  state: TickerState,
) -> actor.Next(TickerMessage, TickerState) {
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
    TickForward(client) -> {
      process.send(client, Error(UnknownError))
      actor.continue(state)
    }
  }
}

pub fn create_ticker() -> Ticker {
  let assert Ok(actor) = actor.start(TickerState, handle_message)

  Ticker(actor)
}

pub fn shutdown(ticker: Ticker) -> Nil {
  process.send(ticker.actor, Shutdown)
}

pub fn get_pid(ticker: Ticker) -> Result(process.Pid, Nil) {
  process.call(ticker.actor, GetPid, 10)
}

pub fn link_process(ticker: Ticker) -> Result(Nil, Nil) {
  case get_pid(ticker) {
    Ok(pid) ->
      case process.link(pid) {
        True -> Ok(Nil)
        False -> Error(Nil)
      }
    Error(_) -> Error(Nil)
  }
}

pub fn tick_forward(ticker: Ticker) -> Result(TickSuccess, TickFailure) {
  process.call(ticker.actor, TickForward, 10)
}
