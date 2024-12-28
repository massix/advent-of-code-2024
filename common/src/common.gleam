import argv

pub type CommonError {
  InvalidArguments
  FileDoesNotExist
  CouldNotReadFile
}

pub type Exe(t, e) =
  Result(t, e)

pub fn load_argv() -> Exe(String, CommonError) {
  case argv.load().arguments {
    [path] -> Ok(path)
    _ -> Error(InvalidArguments)
  }
}
