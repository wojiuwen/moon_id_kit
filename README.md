# moon_id_kit

使用 MoonBit 编写的多类型唯一标识符库，当前支持 ULID、UUID、NanoID、KSUID、CUID 和 CUID2。

## 功能概览

| 类型 | 主要能力 |
| --- | --- |
| `Ulid` | 生成、解析、校验、字节转换、时间读取 |
| `Uuid` | v4/v7 生成、标准/紧凑/URN 解析、字节转换、版本和变体读取 |
| `MonotonicUlidGenerator` | 在同一实例内生成按字节序单调递增的 ULID |
| `NanoId` | 生成和解析 URL 安全的短随机 ID |
| `Ksuid` | 生成和解析带秒级时间戳的 160 位 ID |
| `Cuid` | 生成和解析固定 25 字符的 `c` 前缀 ID |
| `Cuid2` | 生成和解析固定 24 字符的小写 ID |

所有可能失败的解析、创建和生成操作都返回结构化 `Result`。完整 API 约定请参阅 [api-v1.md](api-v1.md)。

本库生成的 ID 适合标识资源和记录，不应直接用作密码重置令牌、会话令牌或其他需要密码学安全随机数的凭证。批量生成接口对负数数量返回错误；调用方仍应对批量大小和输入长度设置业务侧限制。

## 已实现 API

### ULID

```moonbit
let generated = Ulid::generate()
let fixed_time = Ulid::generate_at(1720000000000)

let randomness : Bytes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
let from_parts = Ulid::from_parts(1720000000000, randomness)

let parsed = Ulid::parse("01HF7YAT3V008J4CT4ANK7F24S")
let valid = Ulid::is_valid("01HF7YAT3V008J4CT4ANK7F24S")
let batch = Ulid::generate_many(3)
```

ULID 使用 Crockford Base32 字符串表示，字符串长度固定为 26 个字符，字节表示固定为 16 字节。解析接受大小写输入，格式化始终输出大写。

### 单调 ULID

```moonbit
let generator = MonotonicUlidGenerator::new()
let first = generator.generate_at(1720000000000)
let second = generator.generate_at(1720000000000)
let batch = generator.generate_many(3)
```

同一个生成器实例会在时间戳相同或回退时递增随机部分；时间戳前进时使用新的时间戳。不同实例之间不保证全局单调性或线程安全性。

### UUID

```moonbit
let uuid = Uuid::generate_v4()
let uuid_v7 = Uuid::generate_v7(1720000000000)
let parsed = Uuid::parse("00112233-4455-6677-8899-aabbccddeeff")
let compact = Uuid::parse_compact("00112233445566778899aabbccddeeff")
let urn = Uuid::parse_urn("urn:uuid:00112233445566778899aabbccddeeff")
```

当前支持标准 36 字符、32 字符紧凑格式和 `urn:uuid:` 格式，并提供：

```moonbit
uuid.to_string()
uuid.version()
uuid.is_rfc_variant()
uuid.is_version(4)
uuid.is_valid(uuid.to_string())
uuid.to_bytes()
Uuid::from_bytes(uuid.to_bytes())
Uuid::parse_any(uuid.to_string())
```

`Uuid::generate_v7` 使用 Unix 毫秒时间戳，`uuid_v7.timestamp_ms()` 可以读取时间字段。`Uuid::generate_many(count)` 可以批量生成 UUID v4。

UUID v6 可以转换为 ULID：

```moonbit
let result = match Uuid::parse("1ee833b0-4c28-64b0-8123-456789abcdef") {
  Ok(value) => Ulid::from_uuid_v6(value)
  Err(error) => Result::Err(error)
}
```

### NanoID

```moonbit
let default_id = NanoId::generate()
let custom_id = NanoId::generate_with_size(32)
let parsed = NanoId::parse("V1StGXR8_Z5jdHi6B-myT")
```

NanoID 默认长度为 21，使用 64 个 URL 安全字符：`_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`。
`NanoId::generate_many(count)` 可以批量生成默认长度的 NanoID。

### KSUID

```moonbit
let generated = Ksuid::generate()
let fixed_time = Ksuid::generate_at(1700000000)

match generated {
  Ok(value) => {
    let text = value.to_string()
    let timestamp = value.timestamp_seconds()
    Ksuid::parse(text)
  }
  Err(error) => Result::Err(error)
}
```

KSUID 使用 20 字节数据和 27 字符 Base62 编码。时间戳使用 KSUID epoch，即 Unix 时间戳 `1400000000` 之后的秒数。
KSUID 还支持 `to_bytes()`、`from_bytes()`、`is_valid()` 和 `generate_many(count)`。

### CUID 和 CUID2

```moonbit
let cuid = Cuid::generate()
let cuid2 = Cuid2::generate()

let parsed_cuid = Cuid::parse("cabcdefghijklmnopqrstuvwx")
let parsed_cuid2 = Cuid2::parse("abcdefghijklmnopqrstuvwx")
```

当前格式约定：

- `Cuid` 固定 25 个字符，以 `c` 开头，后续使用小写 Base36 字符。
- `Cuid2` 固定 24 个字符，首字符为小写字母，其余字符使用小写 Base36 字符。
- CUID 和 CUID2 使用独立类型和解析器，不互相隐式转换。
- `Cuid::generate_many(count)` 和 `Cuid2::generate_many(count)` 支持批量生成。

## 错误处理

ULID 和 UUID 操作使用 `UlidError`，NanoID、KSUID、CUID 和 CUID2 使用 `IdError`。

常见错误包括：

- `InvalidLength`、`InvalidIdLength`：输入长度错误
- `InvalidCharacter`、`InvalidIdCharacter`：包含不支持的字符
- `InvalidLeadingValue`：ULID 首字符超出允许范围
- `InvalidSize`：NanoID 长度不合法
- `InvalidUuidFormat`、`InvalidIdFormat`：输入格式错误
- `TimestampOverflow`、`IdTimestampOutOfRange`：时间戳超出支持范围
- `UnsupportedUuidVersion`：UUID 版本不受支持
- `UnsupportedUuidVariant`：UUID 变体不受支持

错误可以通过 `message()` 获取可读信息，通过 `code()` 获取稳定错误代码。

## 项目结构

```text
moon_id_kit/
├── src/
│   ├── ulid.mbt                 # ULID、UlidError 和 IdError
│   ├── ulid_generator.mbt       # 普通 ULID 生成
│   ├── ulid_monotonic.mbt       # 单调 ULID 生成器
│   ├── ulid_create.mbt          # ULID 创建和校验
│   ├── ulid_string.mbt         # ULID 字符串转换
│   ├── ulid_bytes.mbt          # ULID 字节转换
│   ├── uuid.mbt                # UUID 操作
│   ├── ulid_uuid.mbt           # UUID v6 转 ULID
│   ├── nanoid.mbt              # NanoID
│   ├── ksuid.mbt               # KSUID
│   ├── cuid.mbt                # CUID 和 CUID2
│   ├── constants.mbt           # 内部长度和时间范围常量
│   ├── random_helpers.mbt      # 内部随机字节和随机索引工具
│   ├── alphabet_helpers.mbt    # 内部字符表查找和拒绝采样
│   └── validation_helpers.mbt  # 内部校验和批量生成工具
├── cmd/main/                   # 演示程序
├── api-v1.md                   # API 规范
├── moon.mod.json               # 模块配置
└── README.md
```

## 测试和运行

运行全部测试：

```bash
moon test
```

运行源代码包测试：

```bash
moon test src
```

运行演示程序：

```bash
moon run cmd/main
```

## 许可证

Apache-2.0

## 相关规范

- [ULID Specification](https://github.com/ulid/spec)
- [KSUID Specification](https://github.com/segmentio/ksuid)
- [Nano ID](https://github.com/ai/nanoid)
