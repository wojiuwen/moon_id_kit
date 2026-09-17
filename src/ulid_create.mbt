///| 
/// ULID 创建和验证功能
///| 
pub fn Ulid::from_parts(
  timestamp_ms : UInt64,
  randomness : Bytes,
) -> Result[Ulid, UlidError] {
  // 检查随机字节长度
  if randomness.length() != ULID_RANDOMNESS_LENGTH {
    return Result::Err(InvalidByteLength(ULID_RANDOMNESS_LENGTH, randomness.length()))
  }
  
  // 检查时间戳是否在 48 位范围内
  if timestamp_ms > ULID_MAX_TIMESTAMP {
    return Result::Err(TimestampOverflow(timestamp_ms))
  }
  
  Result::Ok(Ulid::{
    timestamp: timestamp_ms,
    randomness: randomness
  })
}

pub fn Ulid::is_valid(value : String) -> Bool {
  match Ulid::parse(value) {
    Ok(_) => true
    Err(_) => false
  }
}
