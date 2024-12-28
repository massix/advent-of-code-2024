import common
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Day1Error {
  CouldNotReadInput
  CouldNotParseInput
  InvalidCells
  InvalidArguments
}

pub type Cell =
  #(Int, Int)

pub type SortedCells =
  #(List(Int), List(Int))

pub type ExecutionMonad(t) =
  Result(t, Day1Error)

pub fn sort_cells(cells: List(Cell)) -> ExecutionMonad(SortedCells) {
  let sorted_first = cells |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  let sorted_second = cells |> list.sort(fn(a, b) { int.compare(a.1, b.1) })

  #(
    sorted_first |> list.map(fn(cell) { cell.0 }),
    sorted_second |> list.map(fn(cell) { cell.1 }),
  )
  |> Ok
}

pub fn calculate_distance(cells: SortedCells, acc: Int) -> ExecutionMonad(Int) {
  case cells {
    #([], []) -> Ok(acc)
    #([first, ..f_rest], [second, ..s_rest]) ->
      calculate_distance(
        #(f_rest, s_rest),
        acc + int.absolute_value(first - second),
      )
    #(_, _) -> Error(InvalidCells)
  }
}

pub fn calculate_similarity(cells: SortedCells, acc: Int) -> ExecutionMonad(Int) {
  case cells {
    #([], _) -> Ok(acc)
    #([first, ..rest], other_list) -> {
      let occurences =
        list.filter(other_list, fn(n) { n == first })
        |> list.length
      let occurences = first * occurences
      calculate_similarity(#(rest, other_list), acc + occurences)
    }
  }
}

pub fn parse_line(line: String) -> ExecutionMonad(Cell) {
  case string.split(line |> string.trim, on: "   ") {
    [a, b] -> {
      use a_int <- result.try(
        int.parse(a) |> result.map_error(fn(_) { CouldNotParseInput }),
      )
      use b_int <- result.try(
        int.parse(b) |> result.map_error(fn(_) { CouldNotParseInput }),
      )
      Ok(#(a_int, b_int))
    }
    _ -> Error(CouldNotParseInput)
  }
}

pub fn parse_input(path: String) -> ExecutionMonad(List(Cell)) {
  use result <- result.try(
    simplifile.read(path) |> result.map_error(fn(_) { CouldNotReadInput }),
  )

  string.split(result |> string.trim, on: "\n")
  |> list.map(parse_line)
  |> result.all
}

pub fn main() {
  use file_path: String <- result.try(
    common.load_argv()
    |> result.map_error(fn(_) {
      io.println_error(
        "Invalid arguments supplied, run this with ./day1 input_file",
      )
    }),
  )
  use input <- result.try(
    parse_input(file_path)
    |> result.map_error(fn(_) { io.println_error("Could not read input file") }),
  )

  use sorted_cells <- result.try(
    input
    |> sort_cells
    |> result.map_error(fn(_) { io.println_error("Could not parse input file") }),
  )

  use distance <- result.try(
    sorted_cells
    |> calculate_distance(0)
    |> result.map_error(fn(_) {
      io.println_error("Could not calculate distance")
    }),
  )

  io.print("Distance: ")
  io.println(distance |> int.to_string)
  use similarity <- result.try(
    sorted_cells
    |> calculate_similarity(0)
    |> result.map_error(fn(_) {
      io.println_error("Could not calculate similarity")
    }),
  )

  io.print("Similarity: ")
  io.println(similarity |> int.to_string)

  Ok(Nil)
}
