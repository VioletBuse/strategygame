import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import gleam/list
import utils/pid
import game/entities/outpost

pub type OutpostManager {
  OutpostManager(actor: Subject(OutpostManagerMessage))
}

pub type OutpostManagerMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
  CreateOutpost(outpost_type: outpost.OutpostType, units: Int)
  ListOutposts(reply_with: Subject(List(outpost.Outpost)))
  ListOutpostsOfType(
    reply_with: Subject(List(outpost.Outpost)),
    outpost_type: outpost.OutpostType,
  )
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

fn handle_list_outposts(
  message: OutpostManagerMessage,
  state: OutpostManagerState,
) -> actor.Next(OutpostManagerMessage, OutpostManagerState) {
  let assert ListOutposts(client) = message

  process.send(client, state.outposts)
  actor.continue(state)
}

fn handle_list_outposts_of_type(
  message: OutpostManagerMessage,
  state: OutpostManagerState,
) -> actor.Next(OutpostManagerMessage, OutpostManagerState) {
  let assert ListOutpostsOfType(client, outpost_type) = message

  let outpost_list =
    state.outposts
    |> list.filter(fn(outpost) { outpost.get_type(outpost) == outpost_type })

  process.send(client, outpost_list)

  actor.continue(state)
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
    ListOutposts(_) -> handle_list_outposts(message, state)
    ListOutpostsOfType(_, _) -> handle_list_outposts_of_type(message, state)
  }
}

pub fn create_outpost(
  manager: OutpostManager,
  outpost_type outpost_type: outpost.OutpostType,
  units units: Int,
) -> Nil {
  process.send(manager.actor, CreateOutpost(outpost_type, units))
}

pub fn list_outposts(manager: OutpostManager) -> List(outpost.Outpost) {
  process.call(manager.actor, ListOutposts, 10)
}

pub fn list_outposts_by_type(
  manager: OutpostManager,
  outpost_type outpost_type: outpost.OutpostType,
) -> List(outpost.Outpost) {
  let fetcher = fn(subject: Subject(List(outpost.Outpost))) -> OutpostManagerMessage {
    ListOutpostsOfType(subject, outpost_type)
  }

  process.call(manager.actor, fetcher, 10)
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
