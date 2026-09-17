///|
/// UUID 核心实现
///|
pub struct Uuid {
  bytes : Bytes
}

pub fn Uuid::generate() -> Uuid {
  Uuid::generate_v4()
}

pub fn Uuid::generate_v4() -> Uuid {
  let bytes : Array[Byte] = random_bytes(16).to_array()
  bytes[6] = ((bytes[6].to_int() & 0x0F) | 0x40).to_byte()
  bytes[8] = ((bytes[8].to_int() & 0x3F) | 0x80).to_byte()
  Uuid::{ bytes: Bytes::from_array(bytes) }
}

pub fn Uuid::generate_v7(timestamp_ms : UInt64) -> Result[Uuid, UlidError] {
  if timestamp_ms > ULID_MAX_TIMESTAMP {
    return Result::Err(TimestampOverflow(timestamp_ms))
  }
  let bytes : Array[Byte] = random_bytes(16).to_array()
  bytes[0] = (timestamp_ms >> 40).to_byte()
  bytes[1] = (timestamp_ms >> 32).to_byte()
  bytes[2] = (timestamp_ms >> 24).to_byte()
  bytes[3] = (timestamp_ms >> 16).to_byte()
  bytes[4] = (timestamp_ms >> 8).to_byte()
  bytes[5] = timestamp_ms.to_byte()
  bytes[6] = ((bytes[6].to_int() & 0x0F) | 0x70).to_byte()
  bytes[8] = ((bytes[8].to_int() & 0x3F) | 0x80).to_byte()
  Result::Ok(Uuid::{ bytes: Bytes::from_array(bytes) })
}

pub fn Uuid::generate_many(count : Int) -> Result[Array[Uuid], UlidError] {
  if !is_non_negative(count) {
    return Result::Err(InvalidLength(0, count))
  }
  generate_many_with(count, fn() { Result::Ok(Uuid::generate_v4()) })
}

pub fn Uuid::to_bytes(self : Uuid) -> Bytes {
  self.bytes
}

pub fn Uuid::from_bytes(value : Bytes) -> Result[Uuid, UlidError] {
  if value.length() != UUID_BYTE_LENGTH {
    return Result::Err(InvalidByteLength(UUID_BYTE_LENGTH, value.length()))
  }
  Result::Ok(Uuid::{ bytes: value })
}

pub fn Uuid::parse_compact(value : String) -> Result[Uuid, UlidError] {
  if value.length() != UUID_COMPACT_LENGTH {
    return Result::Err(InvalidUuidFormat)
  }
  let output : Array[Char] = []
  for index in 0..<UUID_COMPACT_LENGTH {
    output.push(value.get_char(index).unwrap())
    if index == 7 || index == 11 || index == 15 || index == 19 {
      output.push('-')
    }
  }
  Uuid::parse(String::from_array(output))
}

pub fn Uuid::parse_urn(value : String) -> Result[Uuid, UlidError] {
  if value.length() != UUID_URN_LENGTH ||
    value.code_unit_at(0) != 'u'.to_int().to_uint16() ||
    value.code_unit_at(1) != 'r'.to_int().to_uint16() ||
    value.code_unit_at(2) != 'n'.to_int().to_uint16() ||
    value.code_unit_at(3) != ':'.to_int().to_uint16() ||
    value.code_unit_at(4) != 'u'.to_int().to_uint16() ||
    value.code_unit_at(5) != 'u'.to_int().to_uint16() ||
    value.code_unit_at(6) != 'i'.to_int().to_uint16() ||
    value.code_unit_at(7) != 'd'.to_int().to_uint16() ||
    value.code_unit_at(8) != ':'.to_int().to_uint16() {
    return Result::Err(InvalidUuidFormat)
  }
  Uuid::parse_compact(value[9:41].to_owned())
}

pub fn Uuid::parse_any(value : String) -> Result[Uuid, UlidError] {
  if value.length() == UUID_STRING_LENGTH {
    Uuid::parse(value)
  } else if value.length() == UUID_COMPACT_LENGTH {
    Uuid::parse_compact(value)
  } else {
    Uuid::parse_urn(value)
  }
}

pub fn Uuid::is_version(self : Uuid, version : Int) -> Bool {
  self.version() == version
}

pub fn Uuid::is_valid(value : String) -> Bool {
  result_is_ok(Uuid::parse(value))
}

pub fn Uuid::timestamp_ms(self : Uuid) -> UInt64 {
  (self.bytes[0].to_int().to_uint64() << 40) |
  (self.bytes[1].to_int().to_uint64() << 32) |
  (self.bytes[2].to_int().to_uint64() << 24) |
  (self.bytes[3].to_int().to_uint64() << 16) |
  (self.bytes[4].to_int().to_uint64() << 8) |
  self.bytes[5].to_int().to_uint64()
}

pub fn Uuid::parse(value : String) -> Result[Uuid, UlidError] {
  if value.length() != UUID_STRING_LENGTH {
    return Result::Err(InvalidUuidFormat)
  }
  let hyphens = [8, 13, 18, 23]
  for position in 0..<UUID_STRING_LENGTH {
    if hyphens.contains(position) {
      if value.get_char(position).unwrap() != '-' {
        return Result::Err(InvalidUuidFormat)
      }
    } else if hex_value(value.get_char(position).unwrap()) < 0 {
      return Result::Err(InvalidUuidFormat)
    }
  }
  let bytes : Bytes = [
    for byte_index in 0..<UUID_BYTE_LENGTH => {
      let value_index = if byte_index < 4 {
        byte_index * 2
      } else if byte_index < 6 {
        byte_index * 2 + 1
      } else if byte_index < 8 {
        byte_index * 2 + 2
      } else if byte_index < 10 {
        byte_index * 2 + 3
      } else {
        byte_index * 2 + 4
      }
      let high = hex_value(value.get_char(value_index).unwrap())
      let low = hex_value(value.get_char(value_index + 1).unwrap())
      (high * 16 + low).to_byte()
    }
  ]
  Result::Ok(Uuid::{ bytes: bytes })
}

pub fn Uuid::to_string(self : Uuid) -> String {
  let alphabet = "0123456789abcdef"
  let output : Array[Char] = []
  for byte_index in 0..<16 {
    let byte = self.bytes[byte_index].to_int()
    output.push(alphabet[byte >> 4].to_char().unwrap())
    output.push(alphabet[byte & 0x0F].to_char().unwrap())
    if byte_index == 3 || byte_index == 5 || byte_index == 7 || byte_index == 9 {
      output.push('-')
    }
  }
  String::from_array(output)
}

fn hex_value(character : Char) -> Int {
  if character >= '0' && character <= '9' {
    return character.to_int() - '0'.to_int()
  }
  if character >= 'a' && character <= 'f' {
    return character.to_int() - 'a'.to_int() + 10
  }
  if character >= 'A' && character <= 'F' {
    return character.to_int() - 'A'.to_int() + 10
  }
  -1
}

pub fn Uuid::version(self : Uuid) -> Int {
  // 获取 UUID 版本位（第 6-7 字节的高 4 位）
  let version_byte = self.bytes[6]
  (version_byte.to_int() >> 4) & 0x0F
}

pub fn Uuid::is_rfc_variant(self : Uuid) -> Bool {
  // 检查变体位（第 8 字节的最高 2 位）
  let variant_byte = self.bytes[8]
  (variant_byte & 0xC0) == 0x80
}