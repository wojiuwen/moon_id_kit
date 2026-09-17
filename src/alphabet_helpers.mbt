fn alphabet_value(alphabet : String, character : UInt16) -> Int {
  for index in 0..<alphabet.length() {
    if alphabet.code_unit_at(index) == character {
      return index
    }
  }
  -1
}

fn random_index(bound : Int) -> Int {
  let random = @random.Rand::new()
  let bound_u = bound.to_uint64()
  let max_value : UInt64 = 0xFFFFFFFFFFFFFFFF
  let limit = max_value - (max_value % bound_u)
  let value = random.uint64()
  if value < limit {
    (value % bound_u).to_int()
  } else {
    random_index(bound)
  }
}