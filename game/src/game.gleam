import gleam/io
import gleam/result
import gleam/list
import worldgen/poisson.{poisson}

pub fn main() {
  poisson(5, 5)
  // |> result.map(list.length)
  |> result.map(io.debug)
}
