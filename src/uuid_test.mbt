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

///|
test "UUID v6 converts to ULID" {
  let uuid = match Uuid::parse("1ee833b0-4c28-64b0-8123-456789abcdef") {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let ulid = match Ulid::from_uuid_v6(uuid) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(ulid.timestamp_ms(), 1700000000123)
  assert_eq(
    ulid.to_bytes(),
    [0x01, 0x8B, 0xCF, 0xE5, 0x68, 0x7B, 0x04, 0x8D, 0x15, 0x9E, 0x26, 0xAF, 0x37, 0xBC, 0x00, 0x00],
  )
}

///|
test "UUID v6 conversion validates version and variant" {
  let version_error = match Uuid::parse("00112233-4455-4677-8899-aabbccddeeff") {
    Ok(uuid) => Ulid::from_uuid_v6(uuid)
    Err(error) => Result::Err(error)
  }
  assert_true(version_error is Err(UlidError::UnsupportedUuidVersion(4)))

  let variant_error = match Uuid::parse("1ee833b0-4c28-64b0-c123-456789abcdef") {
    Ok(uuid) => Ulid::from_uuid_v6(uuid)
    Err(error) => Result::Err(error)
  }
  assert_true(variant_error is Err(UlidError::UnsupportedUuidVariant))
}

///|
test "UUID v4 generation sets version and variant" {
  let uuid = Uuid::generate_v4()
  assert_eq(uuid.version(), 4)
  assert_true(uuid.is_rfc_variant())
  let restored = match Uuid::from_bytes(uuid.to_bytes()) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(restored.to_string(), uuid.to_string())
}

///|
test "UUID v7 generation preserves timestamp" {
  let uuid = match Uuid::generate_v7(1700000000123) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(uuid.version(), 7)
  assert_true(uuid.is_rfc_variant())
  assert_eq(uuid.timestamp_ms(), 1700000000123)
}

///|
test "UUID byte conversion validates length" {
  assert_true(Uuid::from_bytes([0, 1, 2]) is Err(UlidError::InvalidByteLength(16, 3)))
}

///|
test "UUID supports compact and URN parsing" {
  let compact = match Uuid::parse_compact("00112233445566778899aabbccddeeff") {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let urn = match Uuid::parse_urn("urn:uuid:00112233445566778899aabbccddeeff") {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(compact.to_string(), "00112233-4455-6677-8899-aabbccddeeff")
  assert_eq(urn.to_string(), compact.to_string())
  assert_true(Uuid::is_valid(compact.to_string()))
  assert_true(Uuid::generate_many(2) is Ok(_))
  assert_true(compact.is_version(6))
  assert_true(Uuid::parse_any(compact.to_string()) is Ok(_))
  assert_true(Uuid::parse_any("00112233445566778899aabbccddeeff") is Ok(_))
  assert_true(Uuid::parse_any("urn:uuid:00112233445566778899aabbccddeeff") is Ok(_))
}
