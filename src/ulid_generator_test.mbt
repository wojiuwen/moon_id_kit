/// ULID 生成器测试。
///
///|
test "generate_at preserves timestamp and creates valid ULID" {
  let result = Ulid::generate_at(1700000000123)
  let value = match result {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(value.timestamp_ms(), 1700000000123)
  assert_true(Ulid::is_valid(value.to_string()))
  assert_eq(value.to_bytes().length(), 16)
}

///|
test "generate_at rejects timestamp overflow" {
  let result = Ulid::generate_at(281474976710656)
  assert_true(result is Err(UlidError::TimestampOverflow(281474976710656)))
}

///|
test "generate uses current timestamp" {
  let result = Ulid::generate()
  let value = match result {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_true(Ulid::is_valid(value.to_string()))
}

///|
test "generate_many returns the requested number of ULIDs" {
  let values = match Ulid::generate_many(4) {
    Ok(values) => values
    Err(error) => fail(error.message())
  }
  assert_eq(values.length(), 4)
  for value in values {
    assert_true(Ulid::is_valid(value.to_string()))
  }
  assert_true(Ulid::generate_many(-1) is Err(UlidError::InvalidLength(0, -1)))
}

///|
test "monotonic generator increments within the same millisecond" {
  let generator = MonotonicUlidGenerator::new()
  let first = match generator.generate_at(1700000000123) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let second = match generator.generate_at(1700000000123) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(first.timestamp_ms(), second.timestamp_ms())
  assert_true(bytes_are_less(first.to_bytes(), second.to_bytes()))
}

///|
test "monotonic generator keeps order when clock moves backward" {
  let generator = MonotonicUlidGenerator::new()
  let first = match generator.generate_at(1700000000123) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let second = match generator.generate_at(1700000000000) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(second.timestamp_ms(), first.timestamp_ms())
  assert_true(bytes_are_less(first.to_bytes(), second.to_bytes()))
}

///|
test "monotonic generator follows a newer timestamp" {
  let generator = MonotonicUlidGenerator::new()
  let value = match generator.generate_at(1700000000123) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let next = match generator.generate_at(1700000000124) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(next.timestamp_ms(), 1700000000124)
  assert_true(bytes_are_less(value.to_bytes(), next.to_bytes()))
}

///|
test "monotonic generator generates batches" {
  let generator = MonotonicUlidGenerator::new()
  let values = match generator.generate_many(3) {
    Ok(values) => values
    Err(error) => fail(error.message())
  }
  assert_eq(values.length(), 3)
  assert_true(MonotonicUlidGenerator::new().generate_many(-1) is Err(UlidError::InvalidLength(0, -1)))
}

fn bytes_are_less(left : Bytes, right : Bytes) -> Bool {
  for index in 0..<left.length() {
    if left[index] < right[index] {
      return true
    }
    if left[index] > right[index] {
      return false
    }
  }
  false
}
