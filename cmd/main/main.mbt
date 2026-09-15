///|
/// mbt-id 核心功能演示。
///
/// 运行：moon run cmd/main
fn main {
  println("=== mbt-id 核心功能演示 ===")
  println("说明：MoonBit 当前使用 println 逐行输出结果。")

  // from_parts：使用明确的毫秒时间戳和 10 字节随机数创建 ULID。
  let deterministic = match
    @src.Ulid::from_parts(1700000000123, [
      0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99,
    ]) {
    Ok(value) => value
    Err(error) => {
      println("from_parts 失败：" + error.message())
      return
    }
  }
  println("1. from_parts 创建 ULID：")
  println(deterministic.to_string())

  // timestamp_ms 和 timestamp_seconds：读取 ULID 的毫秒/秒时间戳。
  println("2. 读取时间戳：")
  println("毫秒：" + deterministic.timestamp_ms().to_string())
  println("秒：" + deterministic.timestamp_seconds().to_string())

  // to_bytes/from_bytes：在固定的 16 字节大端序表示和 ULID 之间转换。
  let raw_bytes = deterministic.to_bytes()
  println("3. 转换为 16 字节：")
  println(raw_bytes.to_string())
  match @src.Ulid::from_bytes(raw_bytes) {
    Ok(value) => println("字节往返成功：" + value.to_string())
    Err(error) => println("字节转换失败：" + error.message())
  }

  // parse/to_string：解析 ULID 字符串，并输出规范的大写 Crockford Base32 字符串。
  println("4. 字符串往返：")
  match @src.Ulid::parse(deterministic.to_string()) {
    Ok(value) => println("解析成功：" + value.to_string())
    Err(error) => println("解析失败：" + error.message())
  }

  // is_valid：只检查字符串是否符合 ULID 的长度、字符和首字符规则。
  println("5. 字符串校验：")
  println(
    "合法：" + @src.Ulid::is_valid(deterministic.to_string()).to_string(),
  )
  println("非法：" + @src.Ulid::is_valid("not-a-ulid").to_string())

  // generate_at：指定时间戳并生成随机部分；generate 使用当前 Unix 毫秒时间。
  println("6. 生成 ULID：")
  match @src.Ulid::generate_at(1700000000123) {
    Ok(value) => println("generate_at：" + value.to_string())
    Err(error) => println("generate_at 失败：" + error.message())
  }
  match @src.Ulid::generate() {
    Ok(value) => println("generate：" + value.to_string())
    Err(error) => println("generate 失败：" + error.message())
  }

  // Uuid::parse/to_string：解析标准 36 字符 UUID，并恢复规范格式。
  println("7. UUID 解析和格式化：")
  match @src.Uuid::parse("1EC9414C-232A-6B00-9A3E-9AAE4E2B3D4C") {
    Ok(uuid) => {
      println("UUID：" + uuid.to_string())
      println("版本：" + uuid.version().to_string())
      println("RFC 变体：" + uuid.is_rfc_variant().to_string())
    }
    Err(error) => println("UUID 解析失败：" + error.message())
  }

  // Ulid::from_uuid_v6：将 RFC 变体的 UUID v6 转换为确定性的 ULID。
  println("8. UUID v6 转 ULID：")
  match @src.Uuid::parse("1ee833b0-4c28-64b0-8123-456789abcdef") {
    Ok(uuid) =>
      match @src.Ulid::from_uuid_v6(uuid) {
        Ok(ulid) => println("转换结果：" + ulid.to_string())
        Err(error) => println("转换失败：" + error.message())
      }
    Err(error) => println("UUID 解析失败：" + error.message())
  }

  // UlidError：非法输入返回结构化错误，可读取 code 和 message。
  println("9. 结构化错误：")
  match @src.Ulid::parse("invalid") {
    Ok(_) => println("意外成功")
    Err(error) => {
      println("错误代码：" + error.code())
      println("错误信息：" + error.message())
    }
  }

  // MonotonicUlidGenerator：在同一实例内保持 ULID 按字节序递增。
  println("10. 单调 ULID 生成器：")
  let monotonic = @src.MonotonicUlidGenerator::new()
  let first_monotonic = monotonic.generate_at(1700000000123)
  let second_monotonic = monotonic.generate_at(1700000000123)
  match (first_monotonic, second_monotonic) {
    (Ok(first), Ok(second)) => {
      println("第一个：" + first.to_string())
      println("第二个：" + second.to_string())
      println("时间戳：" + second.timestamp_ms().to_string())
    }
    (Err(error), _) => println("生成失败：" + error.message())
    (_, Err(error)) => println("生成失败：" + error.message())
  }

  // NanoId：生成默认长度和自定义长度的 URL 安全 ID，并进行解析。
  println("11. NanoID：")
  match @src.NanoId::generate_with_size(24) {
    Ok(value) => {
      let text = value.to_string()
      println("生成结果：" + text)
      println("长度：" + text.length().to_string())
      match @src.NanoId::parse(text) {
        Ok(parsed) => println("解析成功：" + parsed.to_string())
        Err(error) => println("解析失败：" + error.message())
      }
    }
    Err(error) => println("生成失败：" + error.message())
  }

  // Ksuid：使用固定时间生成 20 字节、27 字符的 Base62 ID。
  println("12. KSUID：")
  match @src.Ksuid::generate_at(1700000000) {
    Ok(value) => {
      let text = value.to_string()
      println("生成结果：" + text)
      println("时间戳：" + value.timestamp_seconds().to_string())
      match @src.Ksuid::parse(text) {
        Ok(parsed) => println("解析成功：" + parsed.to_string())
        Err(error) => println("解析失败：" + error.message())
      }
    }
    Err(error) => println("生成失败：" + error.message())
  }

  // Cuid 和 Cuid2：两种独立格式分别生成并解析。
  println("13. CUID：")
  match @src.Cuid::generate() {
    Ok(value) => {
      let text = value.to_string()
      println("生成结果：" + text)
      match @src.Cuid::parse(text) {
        Ok(parsed) => println("解析成功：" + parsed.to_string())
        Err(error) => println("解析失败：" + error.message())
      }
    }
    Err(error) => println("生成失败：" + error.message())
  }

  println("14. CUID2：")
  match @src.Cuid2::generate() {
    Ok(value) => {
      let text = value.to_string()
      println("生成结果：" + text)
      match @src.Cuid2::parse(text) {
        Ok(parsed) => println("解析成功：" + parsed.to_string())
        Err(error) => println("解析失败：" + error.message())
      }
    }
    Err(error) => println("生成失败：" + error.message())
  }
}
