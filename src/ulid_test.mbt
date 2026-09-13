/// ULID 类型和错误类型测试。
///
///| 
test "UlidError code and message" {
  let error = match Ulid::parse("bad") {
    Ok(_) => fail("expected invalid length")
    Err(error) => error
  }
  assert_eq(error.code(), "INVALID_LENGTH")
  assert_eq(error.message(), "Invalid length: expected 26, got 3")

  let overflow = match Ulid::generate_at(281474976710656) {
    Ok(_) => fail("expected timestamp overflow")
    Err(error) => error
  }
  assert_eq(overflow.code(), "TIMESTAMP_OVERFLOW")
  assert_eq(overflow.message(), "Timestamp overflow: 281474976710656")
}

///|
test "timestamp accessors" {
  let value = match Ulid::from_parts(1234567890, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(value.timestamp_ms(), 1234567890)
  assert_eq(value.timestamp_seconds(), 1234567)
}
