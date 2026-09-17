pub struct NanoId {
  value : String
}

const NANOID_ALPHABET : String = "_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const NANOID_DEFAULT_SIZE : Int = 21

pub fn NanoId::generate() -> Result[NanoId, IdError] {
  NanoId::generate_with_size(NANOID_DEFAULT_SIZE)
}

pub fn NanoId::generate_with_size(size : Int) -> Result[NanoId, IdError] {
  if size <= 0 {
    return Result::Err(InvalidSize(size))
  }
  let random = @random.Rand::new()
  let value : Array[Char] = [
    for _ in 0..<size =>
      NANOID_ALPHABET.code_unit_at((random.uint64() % 64).to_int()).to_char().unwrap()
  ]
  Result::Ok(NanoId::{ value: String::from_array(value) })
}

pub fn NanoId::generate_many(count : Int) -> Result[Array[NanoId], IdError] {
  if !is_non_negative(count) {
    return Result::Err(InvalidSize(count))
  }
  generate_many_with(count, fn() { NanoId::generate() })
}

pub fn NanoId::parse(value : String) -> Result[NanoId, IdError] {
  if value.length() == 0 {
    return Result::Err(InvalidIdLength(1, 0))
  }
  for index in 0..<value.length() {
    if nanoid_value(value.code_unit_at(index)) < 0 {
      return Result::Err(
        InvalidIdCharacter(index, value.get_char(index).unwrap()),
      )
    }
  }
  Result::Ok(NanoId::{ value: value })
}

pub fn NanoId::to_string(self : NanoId) -> String {
  self.value
}

pub fn NanoId::is_valid(value : String) -> Bool {
  result_is_ok(NanoId::parse(value))
}

fn nanoid_value(character : UInt16) -> Int {
  alphabet_value(NANOID_ALPHABET, character)
}