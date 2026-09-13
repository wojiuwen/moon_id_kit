/// UUID 解析、格式化和字段读取测试。
///
///|
test "UUID parse and format" {
  let result = Uuid::parse("00112233-4455-6677-8899-aabbccddeeff")
  let uuid = match result {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(uuid.to_string(), "00112233-4455-6677-8899-aabbccddeeff")
  assert_eq(uuid.version(), 6)
  assert_true(uuid.is_rfc_variant())
}

///|
test "UUID accepts uppercase hexadecimal" {
  let lower = match Uuid::parse("00112233-4455-6677-8899-aabbccddeeff") {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let upper = match Uuid::parse("00112233-4455-6677-8899-AABBCCDDEEFF") {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(upper.to_string(), lower.to_string())
}

///|
test "UUID rejects unsupported formats" {
  assert_true(Uuid::parse("00112233445566778899aabbccddeeff") is Err(UlidError::InvalidUuidFormat))
  assert_true(Uuid::parse("{00112233-4455-6677-8899-aabbccddeeff}") is Err(UlidError::InvalidUuidFormat))
  assert_true(Uuid::parse("00112233-4455-6677-8899-aabbccddeefg") is Err(UlidError::InvalidUuidFormat))
}
