import gleam/string
import gleam/int
import gleam/string_builder

const alphabet = "_-1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"

pub fn new(id_length: Int) -> String {
  generation_loop(id_length)
  |> string_builder.to_string
}

pub fn generation_loop(remaining: Int) -> string_builder.StringBuilder {
  case remaining {
    0 -> string_builder.new()
    _ ->
      string_builder.prepend(
        generation_loop(remaining - 1),
        string.slice(alphabet, at_index: int.random(64), length: 1),
      )
  }
}
