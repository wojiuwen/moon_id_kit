pub struct Ksuid {
  bytes : Bytes
}

const KSUID_EPOCH : UInt64 = 1400000000
const KSUID_ALPHABET : String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

pub fn Ksuid::generate() -> Result[Ksuid, IdError] {
  Ksuid::generate_at(get_current_timestamp() / 1000)
}

pub fn Ksuid::generate_at(timestamp_seconds : UInt64) -> Result[Ksuid, IdError] {
  if timestamp_seconds < KSUID_EPOCH || timestamp_seconds - KSUID_EPOCH > 0xFFFFFFFF {
    return Result::Err(IdTimestampOutOfRange(timestamp_seconds))
  }
  let bytes : Array[Byte] = [for _ in 0..<20 => 0]
  let timestamp = timestamp_seconds - KSUID_EPOCH
  bytes[0] = (timestamp >> 24).to_byte()
  bytes[1] = (timestamp >> 16).to_byte()
  bytes[2] = (timestamp >> 8).to_byte()
  bytes[3] = timestamp.to_byte()
  let random = random_bytes(16)
  for index in 4..<20 {
    bytes[index] = random[index - 4]
  }
  Result::Ok(Ksuid::{ bytes: Bytes::from_array(bytes) })
}

pub fn Ksuid::generate_many(count : Int) -> Result[Array[Ksuid], IdError] {
  if count < 0 {
    return Result::Err(InvalidSize(count))
  }
  let output : Array[Ksuid] = []
  for _ in 0..<count {
    match Ksuid::generate() {
      Ok(value) => output.push(value)
      Err(error) => return Result::Err(error)
    }
  }
  Result::Ok(output)
}

pub fn Ksuid::parse(value : String) -> Result[Ksuid, IdError] {
  if value.length() != 27 {
    return Result::Err(InvalidIdLength(27, value.length()))
  }
  let bytes : Array[Byte] = [for _ in 0..<20 => 0]
  for character_index in 0..<27 {
    let digit = ksuid_value(value.code_unit_at(character_index))
    if digit < 0 {
      return Result::Err(
        InvalidIdCharacter(character_index, value.get_char(character_index).unwrap()),
      )
    }
    let mut carry = digit
    for offset in 0..<20 {
      let index = 19 - offset
      let total = bytes[index].to_int() * 62 + carry
      bytes[index] = (total % 256).to_byte()
      carry = total / 256
    }
    if carry != 0 {
      return Result::Err(InvalidIdFormat)
    }
  }
  let result = Ksuid::{ bytes: Bytes::from_array(bytes) }
  if result.timestamp_seconds() < KSUID_EPOCH {
    return Result::Err(IdTimestampOutOfRange(result.timestamp_seconds()))
  }
  Result::Ok(result)
}

pub fn Ksuid::to_string(self : Ksuid) -> String {
  let working : Array[Byte] = [for index in 0..<20 => self.bytes[index]]
  let output : Array[Char] = [for _ in 0..<27 => '0']
  for digit_offset in 0..<27 {
    let mut carry = 0
    for index in 0..<20 {
      let total = carry * 256 + working[index].to_int()
      working[index] = (total / 62).to_byte()
      carry = total % 62
    }
    output[26 - digit_offset] = KSUID_ALPHABET.code_unit_at(carry).to_char().unwrap()
  }
  String::from_array(output)
}

pub fn Ksuid::timestamp_seconds(self : Ksuid) -> UInt64 {
  let timestamp =
    (self.bytes[0].to_int().to_uint64() << 24) |
    (self.bytes[1].to_int().to_uint64() << 16) |
    (self.bytes[2].to_int().to_uint64() << 8) |
    self.bytes[3].to_int().to_uint64()
  KSUID_EPOCH + timestamp
}

pub fn Ksuid::to_bytes(self : Ksuid) -> Bytes {
  self.bytes
}

pub fn Ksuid::from_bytes(value : Bytes) -> Result[Ksuid, IdError] {
  if value.length() != 20 {
    return Result::Err(InvalidIdLength(20, value.length()))
  }
  Result::Ok(Ksuid::{ bytes: value })
}

pub fn Ksuid::is_valid(value : String) -> Bool {
  match Ksuid::parse(value) {
    Ok(_) => true
    Err(_) => false
  }
}

fn ksuid_value(character : UInt16) -> Int {
  alphabet_value(KSUID_ALPHABET, character)
}