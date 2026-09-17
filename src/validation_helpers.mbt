fn[T, E] result_is_ok(value : Result[T, E]) -> Bool {
  match value {
    Ok(_) => true
    Err(_) => false
  }
}

fn is_non_negative(value : Int) -> Bool {
  value >= 0
}