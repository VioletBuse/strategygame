import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import utils/pid
import game/entities/outpost

pub type OutpostManager {
  OutpostManager(actor: Subject(OutpostManagerMessage))
}

pub type OutpostManagerMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
  CreateOutpost(outpost_type: outpost.OutpostType, units: Int)
}

pub type OutpostManagerState {
  OutpostManagerState(outposts: List(outpost.Outpost))
}

fn handle_create_outpost(
  message: OutpostManagerMessage,
  state: OutpostManagerState,
) -> actor.Next(OutpostManagerMessage, OutpostManagerState) {
  let assert CreateOutpost(outpost_type, unit_count) = message

  case outpost_type {
    outpost.Generator -> {
      let new_outpost = outpost.create_generator(unit_count)
      actor.continue(OutpostManagerState([new_outpost, ..state.outposts]))
    }
    outpost.Factory -> {
      let new_outpost = outpost.create_factory(unit_count)
      actor.continue(OutpostManagerState([new_outpost, ..state.outposts]))
    }
    outpost.Mine -> {
      let new_outpost = outpost.create_mine(unit_count)
      actor.continue(OutpostManagerState([new_outpost, ..state.outposts]))
    }
    outpost.Ruin -> {
      let new_outpost = outpost.create_ruin(unit_count)
      actor.continue(OutpostManagerState([new_outpost, ..state.outposts]))
    }
  }
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
    CreateOutpost(_, _) -> handle_create_outpost(message, state)
  }
}

pub fn create_outpost_manager() -> OutpostManager {
  let assert Ok(actor) = actor.start(OutpostManagerState([]), handle_message)

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
