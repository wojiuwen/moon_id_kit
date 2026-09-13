///| 
/// ULID 字符串转换功能
///| 
pub fn Ulid::parse(value : String) -> Result[Ulid, UlidError] {
  if value.length() != 26 {
    return Result::Err(InvalidLength(26, value.length()))
  }

  for index in 0..<26 {
    let digit = base32_value(value[index])
    if digit < 0 {
      return Result::Err(InvalidCharacter(index, value[index].to_char().unwrap()))
    }
  }
  if base32_value(value[0]) > 7 {
    return Result::Err(InvalidLeadingValue)
  }
  let mut timestamp : UInt64 = 0
  for index in 0..<10 {
    timestamp = (timestamp << 5) | base32_value(value.code_unit_at(index)).to_uint64()
  }
  timestamp = timestamp & 0xFFFFFFFFFFFF
  let randomness = decode_randomness(value)
  Ulid::from_parts(timestamp, randomness)
}

pub fn Ulid::to_string(self : Ulid) -> String {
  let bytes = self.to_bytes()
  let alphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
  [
    for digit_index in 0..<26 =>
      alphabet.code_unit_at(encoded_digit(bytes, digit_index)).to_char().unwrap()
  ]
}

fn base32_value(character : UInt16) -> Int {
  let code = character.to_int()
  let normalized = if code >= 97 && code <= 122 {
    code - 32
  } else {
    code
  }
  if normalized >= 48 && normalized <= 57 {
    return normalized - 48
  }
  if normalized >= 65 && normalized <= 72 {
    return normalized - 65 + 10
  }
  match normalized {
    74 => 18
    75 => 19
    77 => 20
    78 => 21
    80 => 22
    81 => 23
    82 => 24
    83 => 25
    84 => 26
    86 => 27
    87 => 28
    88 => 29
    89 => 30
    90 => 31
    _ => -1
  }
}

fn decode_randomness(value : String) -> Bytes {
  let output : Array[Byte] = [for _ in 0..<10 => 0]
  for group_index in 0..<2 {
    let mut group : UInt64 = 0
    for digit_index in 0..<8 {
      let index = 10 + group_index * 8 + digit_index
      group = (group << 5) | base32_value(value.code_unit_at(index)).to_uint64()
    }
    for byte_index in 0..<5 {
      output[group_index * 5 + byte_index] = (group >> (32 - byte_index * 8)).to_byte()
    }
  }
  Bytes::from_array(output)
}

fn encoded_digit(bytes : Bytes, digit_index : Int) -> Int {
  let first_bit = digit_index * 5 - 2
  let mut result = 0
  for bit_index in 0..<5 {
    let source_bit = first_bit + bit_index
    let bit = if source_bit < 0 {
      0
    } else {
      let byte = bytes[source_bit / 8].to_int()
      (byte >> (7 - source_bit % 8)) & 1
    }
    result = (result << 1) | bit
  }
  result
}
