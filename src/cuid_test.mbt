test "cuid generates and round trips" {
  let generated = match Cuid::generate() {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(generated.to_string().length(), 25)
  let parsed = match Cuid::parse(generated.to_string()) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(parsed.to_string(), generated.to_string())
  assert_true(Cuid::is_valid(generated.to_string()))
}

test "cuid rejects malformed strings" {
  assert_true(Cuid::parse("c") is Err(IdError::InvalidIdLength(25, 1)))
  assert_true(Cuid::parse("x000000000000000000000000") is Err(IdError::InvalidIdFormat))
}

test "cuid2 generates and round trips" {
  let generated = match Cuid2::generate() {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(generated.to_string().length(), 24)
  let parsed = match Cuid2::parse(generated.to_string()) {
    Ok(value) => value
    Err(error) => fail(error.message())
  }
  assert_eq(parsed.to_string(), generated.to_string())
  assert_true(Cuid2::is_valid(generated.to_string()))
}

test "cuid2 rejects malformed strings" {
  assert_true(Cuid2::parse("1abcdefghijklmnopqrstuvw") is Err(IdError::InvalidIdFormat))
  assert_true(Cuid2::parse("aABCDEFGHIJKLMNOPQRSTUVW") is Err(_))
}

///|
test "cuid types generate batches" {
  let cuids = match Cuid::generate_many(2) {
    Ok(values) => values
    Err(error) => fail(error.message())
  }
  let cuid2s = match Cuid2::generate_many(2) {
    Ok(values) => values
    Err(error) => fail(error.message())
  }
  assert_eq(cuids.length(), 2)
  assert_eq(cuid2s.length(), 2)
  assert_true(Cuid::generate_many(-1) is Err(IdError::InvalidSize(-1)))
  assert_true(Cuid2::generate_many(-1) is Err(IdError::InvalidSize(-1)))
}