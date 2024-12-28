import day1
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn parse_line_test() {
  "1234   5689"
  |> day1.parse_line
  |> should.be_ok
  |> should.equal(#(1234, 5689))

  "abc   def"
  |> day1.parse_line
  |> should.be_error
  |> should.equal(day1.CouldNotParseInput)

  "1234 5678"
  |> day1.parse_line
  |> should.be_error
  |> should.equal(day1.CouldNotParseInput)
}

pub fn parse_input_test() {
  day1.parse_input("./test/input_test.txt")
  |> should.be_ok
  |> should.equal([#(3, 4), #(4, 3), #(2, 5), #(1, 3), #(3, 9), #(3, 3)])
}

pub fn sort_cells_test() {
  [#(1, 4), #(8, 3), #(2, 5), #(9, 1), #(3, 9), #(3, 3)]
  |> day1.sort_cells
  |> should.be_ok
  |> should.equal(#([1, 2, 3, 3, 8, 9], [1, 3, 3, 4, 5, 9]))
}

pub fn calculate_distance_test() {
  [#(3, 4), #(4, 3), #(2, 5), #(1, 3), #(3, 9), #(3, 3)]
  |> day1.sort_cells
  |> should.be_ok
  |> day1.calculate_distance(0)
  |> should.be_ok
  |> should.equal(11)
}

pub fn calculate_similarity_test() {
  [#(3, 4), #(4, 3), #(2, 5), #(1, 3), #(3, 9), #(3, 3)]
  |> day1.sort_cells
  |> should.be_ok
  |> day1.calculate_similarity(0)
  |> should.be_ok
  |> should.equal(31)
}
