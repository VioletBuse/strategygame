import worldgen/empty_grid
import gleeunit/should

const empty = #(-1.0, -1.0)

pub fn negative_width_test() {
  empty_grid.generate_empty_grid(-1, 3)
  |> should.equal([])
}

pub fn negative_height_test() {
  empty_grid.generate_empty_grid(5, -1)
  |> should.equal([])
}

pub fn zero_zero_empty_grid_test() {
  empty_grid.generate_empty_grid(0, 0)
  |> should.equal([])
}

pub fn one_one_empty_grid_test() {
  empty_grid.generate_empty_grid(1, 1)
  |> should.equal([[empty]])
}

pub fn three_three_empty_grid_test() {
  empty_grid.generate_empty_grid(3, 3)
  |> should.equal([
    [empty, empty, empty],
    [empty, empty, empty],
    [empty, empty, empty],
  ])
}

pub fn nine_nine_empty_grid_test() {
  empty_grid.generate_empty_grid(9, 9)
  |> should.equal([
    [empty, empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty, empty, empty, empty, empty],
  ])
}
