test "ksuid generates and round trips" {
  let generated = match Ksuid::generate_at(1700000000) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let encoded = generated.to_string()
  assert_eq(encoded.length(), 27)
  let parsed = match Ksuid::parse(encoded) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(parsed.to_string(), encoded)
  assert_eq(parsed.timestamp_seconds(), 1700000000)
}

test "ksuid rejects timestamps outside its range" {
  assert_true(Ksuid::generate_at(1399999999) is Err(IdError::IdTimestampOutOfRange(1399999999)))
}

test "ksuid rejects malformed strings" {
  assert_true(Ksuid::parse("0") is Err(IdError::InvalidIdLength(27, 1)))
  assert_true(Ksuid::parse("00000000000000000000000000!") is Err(IdError::InvalidIdCharacter(26, '!')))
}

///|
test "ksuid generates batches" {
  let values = match Ksuid::generate_many(3) {
    Ok(values) => values
    Err(error) => fail(error.message())
  }
  assert_eq(values.length(), 3)
  assert_true(Ksuid::generate_many(-1) is Err(IdError::InvalidSize(-1)))
}

///|
test "ksuid byte conversion validates length" {
  let value = match Ksuid::generate_at(1700000000) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let restored = match Ksuid::from_bytes(value.to_bytes()) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(restored.to_string(), value.to_string())
  assert_true(Ksuid::from_bytes([0, 1]) is Err(IdError::InvalidIdLength(20, 2)))
  assert_true(Ksuid::is_valid(value.to_string()))
}