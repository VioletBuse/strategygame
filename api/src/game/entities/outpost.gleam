import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/dynamic

pub type Outpost {
  Outpost(actor: Subject(OutpostMessage))
}

pub type OutpostMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
  GetType(reply_with: Subject(OutpostType))
}

pub type OutpostType {
  Factory
  Generator
  Mine
  Ruin
}

pub type OutpostState {
  FactoryState
  GeneratorState
  MineState
  RuinState
}

fn handle_message(
  message: OutpostMessage,
  state: OutpostState,
) -> actor.Next(OutpostMessage, OutpostState) {
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
    GetType(client) -> {
      case state {
        FactoryState -> {
          process.send(client, Factory)
        }
        GeneratorState -> {
          process.send(client, Generator)
        }
        MineState -> {
          process.send(client, Mine)
        }
        RuinState -> {
          process.send(client, Ruin)
        }
      }

      actor.continue(state)
    }
  }
}

pub fn get_outpost_pid(outpost: Outpost) -> Result(process.Pid, Nil) {
  process.call(outpost.actor, GetPid, 10)
}

pub fn get_outpost_type(outpost: Outpost) -> OutpostType {
  process.call(outpost.actor, GetType, 10)
}

pub fn shutdown_outpost(outpost: Outpost) -> Nil {
  process.send(outpost.actor, Shutdown)
}

pub fn link_outpost_process(outpost: Outpost) -> Result(Nil, Nil) {
  case get_outpost_pid(outpost) {
    Ok(pid) ->
      case process.link(pid) {
        True -> Ok(Nil)
        False -> Error(Nil)
      }
    Error(_) -> Error(Nil)
  }
}

pub fn create_factory() -> Outpost {
  let assert Ok(actor) = actor.start(FactoryState, handle_message)

  Outpost(actor)
}

pub fn create_generator() -> Outpost {
  let assert Ok(actor) = actor.start(GeneratorState, handle_message)

  Outpost(actor)
}
