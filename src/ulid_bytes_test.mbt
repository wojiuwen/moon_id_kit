/// ULID 字节序列化测试。
///
///|
test "to_bytes uses big endian and round trips" {
  let value = match Ulid::from_parts(0x010203040506, [0x10, 0x20, 0x30, 0x40, 0x50, 0x60, 0x70, 0x80, 0x90, 0xA0]) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let expected : Bytes = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x10, 0x20, 0x30, 0x40, 0x50, 0x60, 0x70, 0x80, 0x90, 0xA0]
  assert_eq(value.to_bytes(), expected)

  let restored = match Ulid::from_bytes(expected) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(restored.to_bytes(), expected)
  assert_eq(restored.timestamp_ms(), 0x010203040506)
}

///|
test "from_bytes rejects invalid length" {
  let result = Ulid::from_bytes([0, 1, 2])
  assert_true(result is Err(UlidError::InvalidByteLength(16, 3)))
}
