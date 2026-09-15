test "nanoid generates the default size" {
  let result = NanoId::generate()
  let value = match result {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(value.to_string().length(), 21)
  assert_true(NanoId::is_valid(value.to_string()))
}

test "nanoid supports custom size and parsing" {
  let generated = match NanoId::generate_with_size(32) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  let parsed = match NanoId::parse(generated.to_string()) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(parsed.to_string(), generated.to_string())
}

test "nanoid rejects invalid input" {
  assert_true(NanoId::generate_with_size(0) is Err(IdError::InvalidSize(0)))
  assert_true(NanoId::parse("bad space") is Err(IdError::InvalidIdCharacter(3, ' ')))
}

///|
test "nanoid generates batches" {
  let values = match NanoId::generate_many(3) {
    Ok(values) => values
    Err(error) => fail(error.message())
  }
  assert_eq(values.length(), 3)
  assert_true(NanoId::generate_many(-1) is Err(IdError::InvalidSize(-1)))
}