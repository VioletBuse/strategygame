import gleam/io
import worldgen/poisson.{poisson}

pub fn main() {
  poisson(4, 4)
  |> io.debug
}
