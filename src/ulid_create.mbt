///| 
/// ULID 创建和验证功能
///| 
pub fn Ulid::from_parts(
  timestamp_ms : UInt64,
  randomness : Bytes,
) -> Result[Ulid, UlidError] {
  // 检查随机字节长度
  if randomness.length() != 10 {
    return Result::Err(InvalidByteLength(10, randomness.length()))
  }
  
  // 检查时间戳是否在 48 位范围内
  if timestamp_ms > 0xFFFFFFFFFFFF {
    return Result::Err(TimestampOverflow(timestamp_ms))
  }
  
  Result::Ok(Ulid::{
    timestamp: timestamp_ms,
    randomness: randomness
  })
}

pub fn Ulid::is_valid(value : String) -> Bool {
  // 检查长度
  if value.length() != 26 {
    return false
  }

  if base32_value(value[0]) > 7 {
    return false
  }

  for i in 0..<value.length() {
    if base32_value(value.code_unit_at(i)) < 0 {
      return false
    }
  }
  
  true
}
