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
