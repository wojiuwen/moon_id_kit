/// ULID 创建和合法性校验测试。
///
///|
test "from_parts validates timestamp and randomness" {
  let valid = Ulid::from_parts(0xFFFFFFFFFFFF, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
  assert_true(valid is Ok(_))

  let bad_randomness = Ulid::from_parts(1, [0, 1, 2])
  assert_true(bad_randomness is Err(UlidError::InvalidByteLength(10, 3)))

  let bad_timestamp = Ulid::from_parts(281474976710656, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
  assert_true(bad_timestamp is Err(UlidError::TimestampOverflow(281474976710656)))
}

///|
test "is_valid checks length alphabet and leading value" {
  assert_true(Ulid::is_valid("00000000000000000000000000"))
  assert_true(Ulid::is_valid("7ZZZZZZZZZZZZZZZZZZZZZZZZZ"))
  assert_false(Ulid::is_valid("80000000000000000000000000"))
  assert_false(Ulid::is_valid("0000000000000000000000000"))
  assert_false(Ulid::is_valid("0000000000000000000000000I"))
}
