const BASE36_ALPHABET : String = "0123456789abcdefghijklmnopqrstuvwxyz"
const CUID_TIMESTAMP_MAX : UInt64 = 2821109907455

pub struct Cuid {
  value : String
}

pub fn Cuid::generate() -> Result[Cuid, IdError] {
  let timestamp = get_current_timestamp()
  if timestamp > CUID_TIMESTAMP_MAX {
    return Result::Err(IdTimestampOutOfRange(timestamp))
  }
  let value : Array[Char] = []
  value.push('c')
  for character in encode_base36_fixed(timestamp, 8) {
    value.push(character)
  }
  for character in random_base36_string(16) {
    value.push(character)
  }
  Result::Ok(Cuid::{ value: String::from_array(value) })
}

pub fn Cuid::generate_many(count : Int) -> Result[Array[Cuid], IdError] {
  if count < 0 {
    return Result::Err(InvalidSize(count))
  }
  let output : Array[Cuid] = []
  for _ in 0..<count {
    match Cuid::generate() {
      Ok(value) => output.push(value)
      Err(error) => return Result::Err(error)
    }
  }
  Result::Ok(output)
}

pub fn Cuid::parse(value : String) -> Result[Cuid, IdError] {
  if value.length() != 25 {
    return Result::Err(InvalidIdLength(25, value.length()))
  }
  if value.code_unit_at(0) != 'c'.to_int().to_uint16() {
    return Result::Err(InvalidIdFormat)
  }
  for index in 1..<25 {
    if base36_value(value.code_unit_at(index)) < 0 {
      return Result::Err(
        InvalidIdCharacter(index, value.get_char(index).unwrap()),
      )
    }
  }
  Result::Ok(Cuid::{ value: value })
}

pub fn Cuid::to_string(self : Cuid) -> String {
  self.value
}

pub fn Cuid::is_valid(value : String) -> Bool {
  match Cuid::parse(value) {
    Ok(_) => true
    Err(_) => false
  }
}

pub struct Cuid2 {
  value : String
}

pub fn Cuid2::generate() -> Result[Cuid2, IdError] {
  let value : Array[Char] = []
  value.push((97 + random_index(26)).to_byte().to_char())
  for character in random_base36_string(23) {
    value.push(character)
  }
  Result::Ok(Cuid2::{ value: String::from_array(value) })
}

pub fn Cuid2::generate_many(count : Int) -> Result[Array[Cuid2], IdError] {
  if count < 0 {
    return Result::Err(InvalidSize(count))
  }
  let output : Array[Cuid2] = []
  for _ in 0..<count {
    match Cuid2::generate() {
      Ok(value) => output.push(value)
      Err(error) => return Result::Err(error)
    }
  }
  Result::Ok(output)
}

pub fn Cuid2::parse(value : String) -> Result[Cuid2, IdError] {
  if value.length() != 24 {
    return Result::Err(InvalidIdLength(24, value.length()))
  }
  let first = value.code_unit_at(0).to_int()
  if first < 97 || first > 122 {
    return Result::Err(InvalidIdFormat)
  }
  for index in 1..<24 {
    if base36_value(value.code_unit_at(index)) < 0 {
      return Result::Err(
        InvalidIdCharacter(index, value.get_char(index).unwrap()),
      )
    }
  }
  Result::Ok(Cuid2::{ value: value })
}

pub fn Cuid2::to_string(self : Cuid2) -> String {
  self.value
}

pub fn Cuid2::is_valid(value : String) -> Bool {
  match Cuid2::parse(value) {
    Ok(_) => true
    Err(_) => false
  }
}

fn encode_base36_fixed(input : UInt64, size : Int) -> Array[Char] {
  let output : Array[Char] = [for _ in 0..<size => '0']
  let mut value = input
  for offset in 0..<size {
    let index = size - 1 - offset
    output[index] = BASE36_ALPHABET.code_unit_at((value % 36).to_int()).to_char().unwrap()
    value = value / 36
  }
  output
}

fn random_base36_string(size : Int) -> Array[Char] {
  [
    for _ in 0..<size =>
      BASE36_ALPHABET.code_unit_at(random_index(36)).to_char().unwrap()
  ]
}

fn base36_value(character : UInt16) -> Int {
  alphabet_value(BASE36_ALPHABET, character)
}