fn[T, E] result_is_ok(value : Result[T, E]) -> Bool {
  match value {
    Ok(_) => true
    Err(_) => false
  }
}

fn is_non_negative(value : Int) -> Bool {
  value >= 0
}

fn[T, E] generate_many_with(
  count : Int,
  generator : () -> Result[T, E],
) -> Result[Array[T], E] {
  let output : Array[T] = []
  for _ in 0..<count {
    match generator() {
      Ok(value) => output.push(value)
      Err(error) => return Result::Err(error)
    }
  }
  Result::Ok(output)
}