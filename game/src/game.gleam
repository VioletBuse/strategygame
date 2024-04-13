import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/int
import worldgen/main

pub fn main() {
  let world = main.create(main.Standard([12_345, 2346, 30_425]))

  result.map(world, fn(world) {
    let player_count = list.length(world.players)
    let outpost_count = list.length(world.outposts)
    let specialist_count = list.length(world.specialists)

    io.debug(world)

    io.println(string.concat(["generated world"]))
    io.println(
      string.concat(["world contains ", int.to_string(player_count), " players"]),
    )
    io.println(
      string.concat([
        "world contains ",
        int.to_string(outpost_count),
        " outposts",
      ]),
    )
    io.println(
      string.concat([
        "world contains ",
        int.to_string(specialist_count),
        " specialists",
      ]),
    )
  })
}
