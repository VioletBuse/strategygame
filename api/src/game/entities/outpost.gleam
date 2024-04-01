import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import utils/pid

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

pub type BaseOutpostState {
  BaseOutpostState(units: Int)
}

pub type SpecializedOutpostState {
  FactoryState
  GeneratorState
  MineState
  RuinState
}

pub type OutpostState {
  OutpostState(base: BaseOutpostState, specialized: SpecializedOutpostState)
}

fn handle_message(
  message: OutpostMessage,
  state: OutpostState,
) -> actor.Next(OutpostMessage, OutpostState) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    GetPid(client) -> {
      pid.send_pid(client)
      actor.continue(state)
    }
    GetType(client) -> {
      case state.specialized {
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

pub fn get_pid(outpost: Outpost) -> Result(process.Pid, Nil) {
  process.call(outpost.actor, GetPid, 10)
}

pub fn get_type(outpost: Outpost) -> OutpostType {
  process.call(outpost.actor, GetType, 10)
}

pub fn shutdown(outpost: Outpost) -> Nil {
  process.send(outpost.actor, Shutdown)
}

pub fn link_process(outpost: Outpost) -> Result(Nil, Nil) {
  get_pid(outpost)
  |> pid.link_actor
}

pub fn create_factory(units: Int) -> Outpost {
  let assert Ok(actor) =
    actor.start(
      OutpostState(BaseOutpostState(units), FactoryState),
      handle_message,
    )

  Outpost(actor)
}

pub fn create_generator(units: Int) -> Outpost {
  let assert Ok(actor) =
    actor.start(
      OutpostState(BaseOutpostState(units), GeneratorState),
      handle_message,
    )

  Outpost(actor)
}
