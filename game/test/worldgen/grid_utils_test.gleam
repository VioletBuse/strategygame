import worldgen/grid_utils
import gleam/int
import gleeunit/should

const dummy = #(0.23, 4.56)

const empty = #(-1.0, -1.0)

pub fn zero_size_sizing_test() {
  grid_utils.size([])
  |> should.equal(Ok(#(0, 0)))
}

pub fn one_zero_sizing_test() {
  grid_utils.size([[]])
  |> should.equal(Ok(#(1, 0)))
}

pub fn one_one_sizing_test() {
  grid_utils.size([[dummy]])
  |> should.equal(Ok(#(1, 1)))
}

pub fn three_four_sizing_test() {
  grid_utils.size([
    [dummy, dummy, dummy, dummy],
    [dummy, dummy, dummy, dummy],
    [dummy, dummy, dummy, dummy],
  ])
  |> should.equal(Ok(#(3, 4)))
}

pub fn sizing_test_should_error() {
  grid_utils.size([[dummy, dummy, dummy], [dummy, dummy], [dummy, dummy, dummy]])
  |> should.equal(Error(Nil))
}

pub fn clamp_error_test() {
  grid_utils.clamped_point(Error(Nil), 2, 4)
  |> should.equal(Error(Nil))
}

pub fn clamp_zero_zero_zero_test() {
  grid_utils.clamped_point(Ok(#(0, 0)), 0, 0)
  |> should.equal(Ok(#(0, 0)))
}

pub fn clamp_something_zero_zero_test() {
  grid_utils.clamped_point(Ok(#(4, 5)), 0, 0)
  |> should.equal(Ok(#(0, 0)))
}

pub fn clamp_should_not_change_test() {
  grid_utils.clamped_point(Ok(#(9, 10)), 3, 4)
  |> should.equal(Ok(#(3, 4)))
}

pub fn clamp_at_limit_test() {
  grid_utils.clamped_point(Ok(#(10, 10)), 10, 10)
  |> should.equal(Ok(#(0, 0)))
}

pub fn clamp_should_change_x_test() {
  grid_utils.clamped_point(Ok(#(10, 10)), 12, 3)
  |> should.equal(Ok(#(2, 3)))
}

pub fn clamp_should_change_y_test() {
  grid_utils.clamped_point(Ok(#(10, 10)), 3, 12)
  |> should.equal(Ok(#(3, 2)))
}

pub fn clamp_should_change_both_test() {
  grid_utils.clamped_point(Ok(#(10, 10)), 12, 12)
  |> should.equal(Ok(#(2, 2)))
}

pub fn clamp_should_change_x_negative_test() {
  grid_utils.clamped_point(Ok(#(10, 10)), -1, 5)
  |> should.equal(Ok(#(9, 5)))
}

pub fn clamp_should_change_y_negative_test() {
  grid_utils.clamped_point(Ok(#(10, 10)), 7, -3)
  |> should.equal(Ok(#(7, 7)))
}

pub fn clamp_should_change_both_negative_test() {
  grid_utils.clamped_point(Ok(#(10, 10)), -4, -3)
  |> should.equal(Ok(#(6, 7)))
}

pub fn get_at_empty_grid_test() {
  grid_utils.at_point([], Ok(#(2, 3)))
  |> should.equal(Error(Nil))
}

pub fn get_at_one_one_grid_test() {
  grid_utils.at_point([[dummy]], Ok(#(0, 0)))
  |> should.equal(Ok(dummy))
}

pub fn get_at_grid_test() {
  grid_utils.at_point(
    [
      [dummy, dummy, dummy],
      [dummy, dummy, dummy],
      [dummy, #(0.23, 0.45), dummy],
    ],
    Ok(#(2, 1)),
  )
  |> should.equal(Ok(#(0.23, 0.45)))
}

pub fn grid_write_basic_test() {
  grid_utils.write_point([[dummy, dummy], [dummy, dummy]], 0, 1, #(0.0, 0.0))
  |> should.equal(Ok([[dummy, #(0.0, 0.0)], [dummy, dummy]]))
}

pub fn grid_write_out_of_bounds_test() {
  grid_utils.write_point(
    [[dummy, dummy, dummy], [dummy, dummy, dummy]],
    2,
    5,
    #(4.5, 6.7),
  )
  |> should.equal(Error(Nil))
}

pub fn list_range_test() {
  grid_utils.list_range([0, 1, 2, 3, 4, 5, 6], 2, 5)
  |> should.equal([2, 3, 4])
}

pub fn sized_window_basic_test() {
  grid_utils.sized_window(
    [
      [
        #(0.0, 0.0),
        #(0.0, 1.0),
        #(0.0, 2.0),
        #(0.0, 3.0),
        #(0.0, 4.0),
        #(0.0, 5.0),
      ],
      [
        #(1.0, 0.0),
        #(1.0, 1.0),
        #(1.0, 2.0),
        #(1.0, 3.0),
        #(1.0, 4.0),
        #(1.0, 5.0),
      ],
      [
        #(2.0, 0.0),
        #(2.0, 1.0),
        #(2.0, 2.0),
        #(2.0, 3.0),
        #(2.0, 4.0),
        #(2.0, 5.0),
      ],
      [
        #(3.0, 0.0),
        #(3.0, 1.0),
        #(3.0, 2.0),
        #(3.0, 3.0),
        #(3.0, 4.0),
        #(3.0, 5.0),
      ],
      [
        #(4.0, 0.0),
        #(4.0, 1.0),
        #(4.0, 2.0),
        #(4.0, 3.0),
        #(4.0, 4.0),
        #(4.0, 5.0),
      ],
      [
        #(5.0, 0.0),
        #(5.0, 1.0),
        #(5.0, 2.0),
        #(5.0, 3.0),
        #(5.0, 4.0),
        #(5.0, 5.0),
      ],
    ],
    21,
    0,
    0,
  )
  |> should.equal(Ok([]))
}

pub fn grid_window_basic_test() {
  grid_utils.window(
    [
      [#(0.0, 0.0), #(0.0, 1.0), #(0.0, 2.0)],
      [#(1.0, 0.0), #(1.0, 1.0), #(1.0, 2.0)],
      [#(2.0, 0.0), #(2.0, 1.0), #(2.0, 2.0)],
    ],
    0,
    0,
  )
  |> should.equal(
    Ok([
      [#(2.0, 2.0), #(2.0, 0.0), #(2.0, 1.0)],
      [#(0.0, 2.0), #(0.0, 0.0), #(0.0, 1.0)],
      [#(1.0, 2.0), #(1.0, 0.0), #(1.0, 1.0)],
    ]),
  )
}

pub fn grid_window_test_2_test() {
  grid_utils.window(
    [
      [
        #(0.0, 0.0),
        #(0.0, 1.0),
        #(0.0, 2.0),
        #(0.0, 3.0),
        #(0.0, 4.0),
        #(0.0, 5.0),
      ],
      [
        #(1.0, 0.0),
        #(1.0, 1.0),
        #(1.0, 2.0),
        #(1.0, 3.0),
        #(1.0, 4.0),
        #(1.0, 5.0),
      ],
      [
        #(2.0, 0.0),
        #(2.0, 1.0),
        #(2.0, 2.0),
        #(2.0, 3.0),
        #(2.0, 4.0),
        #(2.0, 5.0),
      ],
      [
        #(3.0, 0.0),
        #(3.0, 1.0),
        #(3.0, 2.0),
        #(3.0, 3.0),
        #(3.0, 4.0),
        #(3.0, 5.0),
      ],
      [
        #(4.0, 0.0),
        #(4.0, 1.0),
        #(4.0, 2.0),
        #(4.0, 3.0),
        #(4.0, 4.0),
        #(4.0, 5.0),
      ],
      [
        #(5.0, 0.0),
        #(5.0, 1.0),
        #(5.0, 2.0),
        #(5.0, 3.0),
        #(5.0, 4.0),
        #(5.0, 5.0),
      ],
      [
        #(6.0, 0.0),
        #(6.0, 1.0),
        #(6.0, 2.0),
        #(6.0, 3.0),
        #(6.0, 4.0),
        #(6.0, 5.0),
      ],
    ],
    3,
    4,
  )
  |> should.equal(
    Ok([
      [#(2.0, 3.0), #(2.0, 4.0), #(2.0, 5.0)],
      [#(3.0, 3.0), #(3.0, 4.0), #(3.0, 5.0)],
      [#(4.0, 3.0), #(4.0, 4.0), #(4.0, 5.0)],
    ]),
  )
}

pub fn iterate_basic_test() {
  grid_utils.iterate(
    [[dummy, dummy, dummy], [dummy, dummy, dummy], [dummy, dummy, dummy]],
    fn(grid, x, y) {
      case
        grid_utils.write_point(grid, x, y, #(int.to_float(x), int.to_float(y)))
      {
        Ok(grid) -> grid
        _ -> panic as "should be able to run"
      }
    },
  )
  |> should.equal(
    Ok([
      [#(0.0, 0.0), #(0.0, 1.0), #(0.0, 2.0)],
      [#(1.0, 0.0), #(1.0, 1.0), #(1.0, 2.0)],
      [#(2.0, 0.0), #(2.0, 1.0), #(2.0, 2.0)],
    ]),
  )
}

pub fn export_empty_grid_test() {
  grid_utils.export_grid([])
  |> should.equal([])
}

pub fn export_empty_grid_2_test() {
  grid_utils.export_grid([
    [empty, empty, empty, empty],
    [empty, empty, empty, empty],
    [empty, empty, empty, empty],
    [empty, empty, empty, empty],
  ])
  |> should.equal([])
}

pub fn export_grid_with_one_point_test() {
  grid_utils.export_grid([
    [empty, empty, empty, #(0.5, 0.5), empty],
    [empty, empty, empty, empty, empty],
    [empty, empty, empty, empty, empty],
  ])
  |> should.equal([#(0.5, 3.5)])
}

pub fn export_grid_with_two_points_test() {
  grid_utils.export_grid([
    [empty, #(0.5, 0.5), empty],
    [empty, empty, empty],
    [empty, empty, #(0.5, 0.5)],
  ])
  |> should.equal([#(0.5, 1.5), #(2.5, 2.5)])
}
