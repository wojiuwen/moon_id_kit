/// UUID v6 到 ULID 的转换。
///
/// UUID v6 的时间戳使用 Gregorian epoch 起的 100 纳秒单位，UUID 的
/// 时钟序列和节点字段组成 62 位随机数据。
pub fn Ulid::from_uuid_v6(value : Uuid) -> Result[Ulid, UlidError] {
  let version = value.version()
  if version != 6 {
    return Result::Err(UnsupportedUuidVersion(version))
  }
  if !value.is_rfc_variant() {
    return Result::Err(UnsupportedUuidVariant)
  }

  let uuid_timestamp =
    (value.bytes[0].to_int().to_uint64() << 52) |
    (value.bytes[1].to_int().to_uint64() << 44) |
    (value.bytes[2].to_int().to_uint64() << 36) |
    (value.bytes[3].to_int().to_uint64() << 28) |
    (value.bytes[4].to_int().to_uint64() << 20) |
    (value.bytes[5].to_int().to_uint64() << 12) |
    ((value.bytes[6].to_int() & 0x0F).to_uint64() << 8) |
    value.bytes[7].to_int().to_uint64()
  let gregorian_offset : UInt64 = 0x01B21DD213814000
  if uuid_timestamp < gregorian_offset {
    return Result::Err(UuidTimestampOutOfRange(uuid_timestamp))
  }
  let timestamp_ms = (uuid_timestamp - gregorian_offset) / 10000
  if timestamp_ms > ULID_MAX_TIMESTAMP {
    return Result::Err(UuidTimestampOutOfRange(timestamp_ms))
  }

  let random =
    ((value.bytes[8].to_int() & 0x3F).to_uint64() << 56) |
    (value.bytes[9].to_int().to_uint64() << 48) |
    (value.bytes[10].to_int().to_uint64() << 40) |
    (value.bytes[11].to_int().to_uint64() << 32) |
    (value.bytes[12].to_int().to_uint64() << 24) |
    (value.bytes[13].to_int().to_uint64() << 16) |
    (value.bytes[14].to_int().to_uint64() << 8) |
    value.bytes[15].to_int().to_uint64()
  let randomness : Bytes = [
    (random >> 54).to_byte(),
    (random >> 46).to_byte(),
    (random >> 38).to_byte(),
    (random >> 30).to_byte(),
    (random >> 22).to_byte(),
    (random >> 14).to_byte(),
    (random >> 6).to_byte(),
    (random << 2).to_byte(),
    0,
    0,
  ]
  Ulid::from_parts(timestamp_ms, randomness)
}