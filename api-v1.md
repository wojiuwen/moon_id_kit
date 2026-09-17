# mbt-id 第一版 API 文档

## 1. 文档定位

本文档定义 `mbt-id` 的第一版 API。该库面向多种常用唯一标识符，当前源码已经实现并可作为稳定 API 基础的类型包括 `Ulid`、`Uuid`、`NanoId`、`Ksuid`、`Cuid` 和 `Cuid2`。

第一版的目标是：

- 提供 ULID、UUID、NanoID、KSUID、CUID 和 CUID2 的生成、解析、校验及序列化。
- 提供 UUID v6 到 ULID 的明确、可验证转换规则。
- 为每一种 ID 保留清晰独立的类型、格式和错误行为。
- 所有公开解析和转换操作使用结构化 `Result` 错误。

## 2. 稳定性约定

当前已经存在于源码并在本文档“已实现 API”中列出的 `pub` 类型和函数，是第一版稳定 API 的基础。函数名称、参数类型、返回类型和错误代码在 `1.0.0` 前应尽量保持兼容。

以下内容不属于当前第一版稳定 API：

- 自定义随机源。
- Wasm JavaScript 接口和 CLI 接口。
- Base32、Base58、Crockford 编码器等内部辅助函数。
- RFC3339 及其他时间格式转换。

库生成的 ID 用于资源标识和记录关联，不应直接作为密码重置令牌、会话令牌或其他安全凭证。当前版本没有公开可注入的密码学随机源 API；安全凭证应使用目标平台提供的专用安全随机数接口。

MoonBit 示例使用方法调用形式，例如 `Ulid::parse(value)`；实际包名和导入方式以包配置为准。

## 3. 已实现 API

### 3.1 `Ulid`

```moonbit
pub struct Ulid {
  timestamp : UInt64
  randomness : Bytes
}
```

实现保证：

- `timestamp` 不超过 ULID 支持的 48 位范围。
- `randomness` 恰好包含 10 个字节。
- 外部调用者不能绕过校验构造非法值。

#### 生成和创建

```moonbit
pub fn Ulid::generate() -> Result[Ulid, UlidError]
pub fn Ulid::generate_at(timestamp_ms : UInt64) -> Result[Ulid, UlidError]
pub fn Ulid::from_parts(
  timestamp_ms : UInt64,
  randomness : Bytes,
) -> Result[Ulid, UlidError]
```

`generate` 使用当前 Unix 毫秒时间和系统随机源。`generate_at` 使用调用者提供的时间戳并生成随机部分。`from_parts` 要求 `randomness` 恰好为 10 个字节，不自动截断或填充输入。

#### 字符串和字节转换

```moonbit
pub fn Ulid::parse(value : String) -> Result[Ulid, UlidError]
pub fn Ulid::to_string(self : Ulid) -> String
pub fn Ulid::is_valid(value : String) -> Bool
pub fn Ulid::to_bytes(self : Ulid) -> Bytes
pub fn Ulid::from_bytes(value : Bytes) -> Result[Ulid, UlidError]
```

字符串规则：

- 输入必须是 26 个字符。
- 接受大小写输入，输出始终为大写。
- 使用 Crockford Base32 字符表。
- 不接受混淆字符替换，不静默忽略空格或其他字符。
- 首字符溢出和非法字符返回结构化错误。

字节规则：`to_bytes` 和 `from_bytes` 使用固定的 16 字节大端序表示；`from_bytes` 只接受 16 字节输入。

#### 时间读取

```moonbit
pub fn Ulid::timestamp_ms(self : Ulid) -> UInt64
pub fn Ulid::timestamp_seconds(self : Ulid) -> UInt64
```

`timestamp_seconds` 返回 `timestamp_ms / 1000` 的整数结果，不进行四舍五入。

### 3.2 `Uuid`

```moonbit
pub struct Uuid {
  bytes : Bytes
}
```

#### 字符串转换和属性读取

```moonbit
pub fn Uuid::generate() -> Uuid
pub fn Uuid::generate_v4() -> Uuid
pub fn Uuid::generate_v7(timestamp_ms : UInt64) -> Result[Uuid, UlidError]
pub fn Uuid::generate_many(count : Int) -> Result[Array[Uuid], UlidError]
pub fn Uuid::parse(value : String) -> Result[Uuid, UlidError]
pub fn Uuid::parse_compact(value : String) -> Result[Uuid, UlidError]
pub fn Uuid::parse_urn(value : String) -> Result[Uuid, UlidError]
pub fn Uuid::parse_any(value : String) -> Result[Uuid, UlidError]
pub fn Uuid::to_string(self : Uuid) -> String
pub fn Uuid::to_bytes(self : Uuid) -> Bytes
pub fn Uuid::from_bytes(value : Bytes) -> Result[Uuid, UlidError]
pub fn Uuid::version(self : Uuid) -> Int
pub fn Uuid::is_version(self : Uuid, version : Int) -> Bool
pub fn Uuid::is_rfc_variant(self : Uuid) -> Bool
pub fn Uuid::is_valid(value : String) -> Bool
pub fn Uuid::timestamp_ms(self : Uuid) -> UInt64
```

第一版支持标准 36 字符格式、32 字符紧凑格式和 `urn:uuid:` 格式：

```text
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

输出使用小写十六进制。花括号格式不属于第一版稳定输入范围。`is_rfc_variant` 用于检查 RFC 变体；UUID v6 转换只接受版本 6 且使用 RFC 变体的 UUID。

`generate` 和 `generate_v4` 生成 RFC 变体的 UUID v4。`generate_v7` 生成带 Unix 毫秒时间戳的 UUID v7；`timestamp_ms` 读取 UUID 前 48 位的时间字段，主要用于 UUID v7。

### 3.3 `MonotonicUlidGenerator`

```moonbit
pub struct MonotonicUlidGenerator

pub fn MonotonicUlidGenerator::new() -> MonotonicUlidGenerator
pub fn MonotonicUlidGenerator::generate(
  self : MonotonicUlidGenerator,
) -> Result[Ulid, UlidError]
pub fn MonotonicUlidGenerator::generate_at(
  self : MonotonicUlidGenerator,
  timestamp_ms : UInt64,
) -> Result[Ulid, UlidError]
pub fn MonotonicUlidGenerator::generate_many(
  self : MonotonicUlidGenerator,
  count : Int,
) -> Result[Array[Ulid], UlidError]
```

```moonbit
pub fn Ulid::generate_many(count : Int) -> Result[Array[Ulid], UlidError]
```

`generate` 使用当前 Unix 毫秒时间。`generate_at` 使用调用者提供的时间戳。生成器保证同一个实例产生的 ULID 按字节序单调递增：

- 当时间戳前进时，使用新的时间戳和新的随机部分。
- 当时间戳相同或回退时，保留上一次使用的时间戳，并将随机部分递增。
- 当随机部分溢出时，将时间戳递增 1，并将随机部分置零。
- 时间戳超过 ULID 支持的 48 位范围时返回 `TimestampOverflow`。

生成器实例维护自己的状态，不同实例之间不保证全局单调性或线程安全性。

### 3.4 UUID v6 转 ULID

```moonbit
pub fn Ulid::from_uuid_v6(value : Uuid) -> Result[Ulid, UlidError]
```

转换规则：

- 输入必须是 RFC 变体的 UUID v6。
- UUID v6 的 60 位时间戳解释为自 Gregorian epoch 起的 100 纳秒单位。
- 转换为 Unix 毫秒时使用整数除法，丢弃不足 1 毫秒的精度。
- 时间戳早于 Unix epoch，或转换结果超过 ULID 的 48 位范围时，返回 `UuidTimestampOutOfRange`。
- UUID 中除版本位和变体位之外的数据放入 ULID 随机部分的高 62 位。
- ULID 随机部分的低 18 位固定为零，因此转换是确定性的，但不是无损转换。
- 第一版不提供 ULID 转 UUID 的公开 API。

### 3.5 `UlidError`

```moonbit
pub enum UlidError {
  InvalidLength(Int, Int)
  InvalidCharacter(Int, Char)
  InvalidLeadingValue
  TimestampOverflow(UInt64)
  InvalidByteLength(Int, Int)
  InvalidUuidFormat
  UnsupportedUuidVersion(Int)
  UnsupportedUuidVariant
  UuidTimestampOutOfRange(UInt64)
}

pub fn UlidError::message(self : UlidError) -> String
pub fn UlidError::code(self : UlidError) -> String
```

`code` 的当前固定取值为：

```text
INVALID_LENGTH
INVALID_CHARACTER
INVALID_LEADING_VALUE
TIMESTAMP_OVERFLOW
INVALID_BYTE_LENGTH
INVALID_UUID_FORMAT
UNSUPPORTED_UUID_VERSION
UNSUPPORTED_UUID_VARIANT
UUID_TIMESTAMP_OUT_OF_RANGE
```

### 3.6 `IdError`

```moonbit
pub enum IdError {
  InvalidSize(Int)
  InvalidIdLength(Int, Int)
  InvalidIdCharacter(Int, Char)
  InvalidIdFormat
  IdTimestampOutOfRange(UInt64)
}

pub fn IdError::message(self : IdError) -> String
pub fn IdError::code(self : IdError) -> String
```

`IdError::code` 的当前固定取值为：

```text
INVALID_SIZE
INVALID_ID_LENGTH
INVALID_ID_CHARACTER
INVALID_ID_FORMAT
ID_TIMESTAMP_OUT_OF_RANGE
```

## 4. 其他已实现 ID 类型

### 4.1 NanoID

NanoID 使用 64 个字符的 URL 安全字母表 `_ - 0-9 a-z A-Z`，默认长度为 21。

API：

```moonbit
pub struct NanoId
pub fn NanoId::generate() -> Result[NanoId, IdError]
pub fn NanoId::generate_with_size(size : Int) -> Result[NanoId, IdError]
pub fn NanoId::generate_many(count : Int) -> Result[Array[NanoId], IdError]
pub fn NanoId::parse(value : String) -> Result[NanoId, IdError]
pub fn NanoId::to_string(self : NanoId) -> String
pub fn NanoId::is_valid(value : String) -> Bool
```

`generate_with_size` 要求长度大于 0；解析只接受非空且全部属于 NanoID 字母表的字符串。

### 4.2 KSUID

KSUID 是 20 字节、27 字符的 Base62 标识符，其中前 4 字节是相对 KSUID epoch（Unix 时间戳 `1400000000`）的秒级时间戳，后 16 字节为随机数据。

API：

```moonbit
pub struct Ksuid
pub fn Ksuid::generate() -> Result[Ksuid, IdError]
pub fn Ksuid::generate_at(timestamp_seconds : UInt64) -> Result[Ksuid, IdError]
pub fn Ksuid::generate_many(count : Int) -> Result[Array[Ksuid], IdError]
pub fn Ksuid::parse(value : String) -> Result[Ksuid, IdError]
pub fn Ksuid::to_string(self : Ksuid) -> String
pub fn Ksuid::to_bytes(self : Ksuid) -> Bytes
pub fn Ksuid::from_bytes(value : Bytes) -> Result[Ksuid, IdError]
pub fn Ksuid::is_valid(value : String) -> Bool
pub fn Ksuid::timestamp_seconds(self : Ksuid) -> UInt64
```

`generate_at` 要求时间戳不早于 KSUID epoch 且相对时间不超过 32 位范围。`parse` 严格要求 27 个 Base62 字符。

### 4.3 CUID / CUID2

本库将 CUID 和 CUID2 作为两个独立类型处理，不共用解析器，也不提供互相隐式转换。

API：

```moonbit
pub struct Cuid
pub struct Cuid2

pub fn Cuid::generate() -> Result[Cuid, IdError]
pub fn Cuid::generate_many(count : Int) -> Result[Array[Cuid], IdError]
pub fn Cuid::parse(value : String) -> Result[Cuid, IdError]
pub fn Cuid::to_string(self : Cuid) -> String

pub fn Cuid2::generate() -> Result[Cuid2, IdError]
pub fn Cuid2::generate_many(count : Int) -> Result[Array[Cuid2], IdError]
pub fn Cuid2::parse(value : String) -> Result[Cuid2, IdError]
pub fn Cuid2::to_string(self : Cuid2) -> String
```

当前格式约定：

- CUID 固定为 25 个字符，以 `c` 开头，后续使用小写 Base36 字符；生成值包含当前毫秒时间字段和随机字段。
- CUID2 固定为 24 个字符，首字符为小写字母，其余字符使用小写 Base36 字符。
- 两种类型都拒绝空字符串、错误长度和不符合字符集的输入。

## 5. 后续扩展

在核心类型稳定后，可以考虑加入：

- 可注入时间源和随机源，便于测试和可复现生成。
- Unix 时间和 RFC3339 转换。
- Base32、Base58 和其他编码的独立公开 API。
- Wasm JavaScript 绑定和 CLI。

这些功能不属于当前第一版稳定 API。
