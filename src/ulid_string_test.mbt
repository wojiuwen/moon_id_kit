/// ULID 字符串转换测试。
///
///|
test "parse and to_string round trip" {
  let value = match Ulid::from_parts(123456789, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let encoded = value.to_string()
  assert_eq(encoded, "00003NQK8N000G40R40M30E209")

  let decoded = match Ulid::parse(encoded) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(decoded.to_bytes(), value.to_bytes())
}

///|
test "parse accepts lowercase input" {
  let upper = "01HF7YAT3V008J4CT4ANK7F24S"
  let lower = "01hf7yat3v008j4ct4ank7f24s"
  let upper_value = match Ulid::parse(upper) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let lower_value = match Ulid::parse(lower) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(lower_value.to_bytes(), upper_value.to_bytes())
  assert_eq(lower_value.to_string(), upper)
}

///|
test "parse returns structured errors" {
  let bad_length = Ulid::parse("short")
  assert_true(bad_length is Err(UlidError::InvalidLength(26, 5)))

  let bad_character = Ulid::parse("0000000000000000000000000I")
  assert_true(bad_character is Err(UlidError::InvalidCharacter(25, 'I')))

  let bad_leading_value = Ulid::parse("80000000000000000000000000")
  assert_true(bad_leading_value is Err(UlidError::InvalidLeadingValue))
}
