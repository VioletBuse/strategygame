import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import utils/pid

pub type Specialist {
  Specialist(actor: Subject(SpecialistMessage))
}

pub type SpecialistMessage {
  Shutdown
  GetPid(reply_with: Subject(Result(process.Pid, Nil)))
}

pub type SpecialistState {
  SpecialistState
}

fn handle_message(
  message: SpecialistMessage,
  state: SpecialistState,
) -> actor.Next(SpecialistMessage, SpecialistState) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    GetPid(client) -> {
      pid.send_pid(client)
      actor.continue(state)
    }
  }
}

pub fn create_specialist() -> Specialist {
  let assert Ok(actor) = actor.start(SpecialistState, handle_message)

  Specialist(actor)
}

pub fn get_pid(specialist: Specialist) -> Result(process.Pid, Nil) {
  process.call(specialist.actor, GetPid, 10)
}

pub fn link_process(specialist: Specialist) -> Result(Nil, Nil) {
  get_pid(specialist)
  |> pid.link_actor
}
