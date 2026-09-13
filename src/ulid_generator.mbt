///|
/// ULID 生成器实现
///|
fn generate_random_bytes() -> Bytes {
  let random = @random.Rand::new()
  Bytes::from_array([
    for _ in 0..<10 => random.uint64().to_byte()
  ])
}

pub fn Ulid::generate() -> Result[Ulid, UlidError] {
  // 获取当前时间戳（Unix 毫秒）
  let timestamp_ms = get_current_timestamp()
  Ulid::generate_at(timestamp_ms)
}

pub fn Ulid::generate_at(timestamp_ms : UInt64) -> Result[Ulid, UlidError] {
  // 检查时间戳是否在 48 位范围内
  if timestamp_ms > 0xFFFFFFFFFFFF {
    return Result::Err(TimestampOverflow(timestamp_ms))
  }
  
  let randomness = generate_random_bytes()
  Ulid::from_parts(timestamp_ms, randomness)
}

fn get_current_timestamp() -> UInt64 {
  @env.now()
}