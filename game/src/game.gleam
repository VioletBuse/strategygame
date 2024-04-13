import gleam/io
import worldgen/main

pub fn main() {
  main.create(main.Standard([12_345, 2346, 30_425]))
  |> io.debug
}
