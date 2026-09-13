///|
/// UUID 核心实现
///|
pub struct Uuid {
  bytes : Bytes
}

pub fn Uuid::parse(value : String) -> Result[Uuid, UlidError] {
  if value.length() != 36 {
    return Result::Err(InvalidUuidFormat)
  }
  let hyphens = [8, 13, 18, 23]
  for position in 0..<36 {
    if hyphens.contains(position) {
      if value.get_char(position).unwrap() != '-' {
        return Result::Err(InvalidUuidFormat)
      }
    } else if hex_value(value.get_char(position).unwrap()) < 0 {
      return Result::Err(InvalidUuidFormat)
    }
  }
  let bytes : Bytes = [
    for byte_index in 0..<16 => {
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