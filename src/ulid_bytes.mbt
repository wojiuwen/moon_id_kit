///| 
/// ULID 字节转换功能

///|
pub fn Ulid::to_bytes(self : Ulid) -> Bytes {
  [
    (self.timestamp >> 40).to_byte(),
    (self.timestamp >> 32).to_byte(),
    (self.timestamp >> 24).to_byte(),
    (self.timestamp >> 16).to_byte(),
    (self.timestamp >> 8).to_byte(),
    self.timestamp.to_byte(),
    ..self.randomness,
  ]
}

///|
pub fn Ulid::from_bytes(value : Bytes) -> Result[Ulid, UlidError] {
  // 检查字节长度
  if value.length() != ULID_BYTE_LENGTH {
    return Result::Err(InvalidByteLength(ULID_BYTE_LENGTH, value.length()))
  }

  // 提取时间戳（前 6 字节）
  let timestamp = (value[0].to_int().to_uint64() << 40) |
    (value[1].to_int().to_uint64() << 32) |
    (value[2].to_int().to_uint64() << 24) |
    (value[3].to_int().to_uint64() << 16) |
    (value[4].to_int().to_uint64() << 8) |
    value[5].to_int().to_uint64()

  // 提取随机数据（后 10 字节）
  let randomness : Bytes = [ for i in 0..<ULID_RANDOMNESS_LENGTH => value[6 + i] ]
  Ulid::from_parts(timestamp, randomness)
}
