///|
/// ULID 生成器实现
///|
pub fn Ulid::generate() -> Result[Ulid, UlidError] {
  // 获取当前时间戳（Unix 毫秒）
  let timestamp_ms = get_current_timestamp()
  Ulid::generate_at(timestamp_ms)
}

pub fn Ulid::generate_at(timestamp_ms : UInt64) -> Result[Ulid, UlidError] {
  // 检查时间戳是否在 48 位范围内
  if timestamp_ms > ULID_MAX_TIMESTAMP {
    return Result::Err(TimestampOverflow(timestamp_ms))
  }
  
  let randomness = random_bytes(10)
  Ulid::from_parts(timestamp_ms, randomness)
}

pub fn Ulid::generate_many(count : Int) -> Result[Array[Ulid], UlidError] {
  if !is_non_negative(count) {
    return Result::Err(InvalidLength(0, count))
  }
  generate_many_with(count, fn() { Ulid::generate() })
}

fn get_current_timestamp() -> UInt64 {
  @env.now()
}