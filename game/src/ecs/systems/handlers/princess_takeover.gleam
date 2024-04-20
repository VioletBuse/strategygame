import gleam/list
import gleam/dict
// import worldgen/grid_utils
import ecs/world.{type World}
import ecs/entities/specialists

pub fn handler(world: World) -> Result(World, Nil) {
  let new_specialists =
    world.specialists
    |> list.group(fn(spec) { spec.ownership.id })
    |> dict.values
    |> list.map(fn(spec_list) {
      let queen =
        list.find(spec_list, fn(spec) {
          spec.specialist_type == specialists.Queen
        })
      let princesses =
        list.filter(spec_list, fn(spec) {
          spec.specialist_type == specialists.Princess
        })

      let remaining =
        list.filter(spec_list, fn(spec) {
          spec.specialist_type != specialists.Queen
          && spec.specialist_type != specialists.Princess
        })

      case queen, princesses {
        Ok(queen), _ -> list.concat([[queen], princesses, remaining])
        Error(_), [princess_to_promote, ..remaining_princesses] -> {
          let new_queen =
            specialists.Specialist(
              ..princess_to_promote,
              specialist_type: specialists.Queen,
            )

          list.concat([[new_queen], remaining_princesses, remaining])
        }
        _, _ -> list.concat([princesses, remaining])
      }
    })
    |> list.concat

  Ok(world.World(..world, specialists: new_specialists))
}
