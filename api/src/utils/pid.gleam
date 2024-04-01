import gleam/erlang/process.{type Subject}
import gleam/dynamic

pub fn send_pid(client: Subject(Result(process.Pid, Nil))) -> Nil {
  let pid = case process.pid_from_dynamic(dynamic.from(process.self())) {
    Ok(pid) -> Ok(pid)
    Error(_) -> Error(Nil)
  }

  process.send(client, pid)
}

pub fn link_actor(pid: Result(process.Pid, Nil)) -> Result(Nil, Nil) {
  case pid {
    Ok(pid) ->
      case process.link(pid) {
        True -> Ok(Nil)
        False -> Error(Nil)
      }
    Error(_) -> Error(Nil)
  }
}
