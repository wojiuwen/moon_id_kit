# mbt-ulid

MoonBit 语言实现的 ULID (Universally Unique Lexicographically Sortable Identifier) 库。

## 概述

`mbt-ulid` 是一个用 MoonBit 语言编写的 ULID 生成和操作库。ULID 是 128 位标识符，具有以下特点：

- **全局唯一性**：像 UUID 一样，ULID 设计为全局唯一
- **字典序可排序**：ULID 可以通过其字符串表示进行排序
- **URL 安全**：ULID 使用 Crockford 的 Base32 编码，提供紧凑且 URL 安全的表示

## 当前开发状态

本库正在积极开发中，以下功能已实现：

### ✅ 已完成功能

1. **核心类型和错误处理**
   - `Ulid` 结构体，包含时间戳和随机数据字段
   - `Uuid` 结构体，用于 UUID 操作
   - `UlidError` 枚举，包含全面的错误类型
   - 结构化错误处理的消息和代码

2. **UUID 核心操作**
   - `Uuid.parse(value)` / `Uuid.to_string()` - UUID 字符串解析和格式化
   - `Uuid.version()` - 提取 UUID 版本（支持 v6）
   - `Uuid.is_rfc_variant()` - 检查 UUID 是否使用 RFC 4122 变体
   - `Ulid.from_uuid_v6(value)` - 将 UUID v6 转换为 ULID

3. **ULID 生成**
   - `Ulid.generate()` - 使用当前时间戳生成 ULID
   - `Ulid.generate_at(timestamp_ms)` - 使用指定时间戳生成 ULID
   - 使用系统随机源生成 10 字节随机数据
   - 使用系统环境获取当前 Unix 毫秒时间戳

4. **ULID 创建和验证**
   - `Ulid.from_parts(timestamp_ms, randomness)` - 从组件创建 ULID
   - `Ulid.is_valid(value)` - 验证 ULID 字符串格式
   - 字节长度验证（必须恰好为 10 字节）
   - 时间戳溢出检查（48 位限制）

5. **ULID 字符串转换**
   - `Ulid.parse(value)` - 从字符串解析 ULID
   - `Ulid.to_string()` - 将 ULID 转换为字符串
   - Crockford Base32 字符验证
   - 长度验证（必须恰好为 26 个字符）
   - 字符位置错误报告

6. **ULID 字节转换**
   - `Ulid.to_bytes()` - 将 ULID 转换为 16 字节大端序格式
   - `Ulid.from_bytes(value)` - 从 16 字节数组创建 ULID
   - 字节长度验证（必须恰好为 16 字节）
   - 时间戳和随机数据的提取/编码

### 🚧 开发中

- 批量生成 API
- Wasm JavaScript 接口
- CLI 扩展功能

## API 文档

完整的 API 规范请参阅 [api-v1.md](api-v1.md)。

## 项目结构

```
moon_ulid/
├── src/
│   ├── ulid.mbt                    # ULID 核心类型和错误处理
│   ├── uuid.mbt                    # UUID 类型和操作
│   ├── ulid_generator.mbt          # ULID 生成函数
│   ├── ulid_create.mbt             # ULID 创建和验证
│   ├── ulid_string.mbt             # 字符串转换函数
│   ├── ulid_bytes.mbt              # 字节转换函数
│   ├── ulid_test.mbt               # ULID 核心测试
│   ├── uuid_test.mbt               # UUID 测试
│   ├── ulid_generator_test.mbt     # 生成器测试
│   ├── ulid_create_test.mbt        # 创建测试
│   ├── ulid_string_test.mbt        # 字符串转换测试
│   └── ulid_bytes_test.mbt         # 字节转换测试
├── cmd/
│   └── main/
│       ├── main.mbt                # 核心功能演示程序
│       └── moon.pkg                # 可执行包配置
├── api-v1.md                       # API 规范
├── moon.mod.json                   # 模块配置
└── README.md                       # 本文件
```

## 使用示例

### 创建 ULID

```moonbit
// 使用当前时间戳生成 ULID
let result = Ulid::generate()

// 使用指定时间戳生成 ULID
let result = Ulid::generate_at(1720000000000)

// 从组件创建 ULID
let timestamp = 1720000000000
let randomness : Bytes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
let result = Ulid::from_parts(timestamp, randomness)
```

### 字符串转换

```moonbit
// 从字符串解析 ULID
let ulid_str = "01HF7YAT3V008J4CT4ANK7F24S"
let result = Ulid::parse(ulid_str)

// 将 ULID 转换为字符串
let ulid_str = ulid.to_string()

// 验证 ULID 字符串
let is_valid = Ulid::is_valid("01HF7YAT3V008J4CT4ANK7F24S")
```

### 字节转换

```moonbit
// 将 ULID 转换为字节
let bytes = ulid.to_bytes()

// 从字节创建 ULID
let result = Ulid::from_bytes(bytes)
```

### UUID 操作

```moonbit
// 解析 UUID
let uuid = Uuid::parse("00112233-4455-6677-8899-aabbccddeeff")

// 获取 UUID 版本
let version = uuid.version()

// 检查 RFC 变体
let is_rfc = uuid.is_rfc_variant()

// 将 UUID v6 转换为 ULID
let result = Ulid::from_uuid_v6(uuid)
```

## 错误处理

所有可能失败的操作都会返回 `Result[Ulid, UlidError]` 或类似类型。错误类型包括：

- `InvalidLength` - 输入长度错误
- `InvalidCharacter` - 输入包含无效字符
- `TimestampOverflow` - 时间戳超过 48 位限制
- `InvalidByteLength` - 字节数组长度错误
- `InvalidUuidFormat` - UUID 格式错误
- `UnsupportedUuidVersion` - 不支持的 UUID 版本
- `UnsupportedUuidVariant` - 不支持的 UUID 变体
- `UuidTimestampOutOfRange` - UUID 时间戳超出有效范围

## 测试

该库为所有已实现的功能提供了全面的测试覆盖：

```bash
moon test src
moon run cmd/main
```

## 贡献

本项目正在积极开发中，欢迎贡献！

## 许可证

Apache-2.0

## 致谢

- ULID 规范：[https://github.com/ulid/spec](https://github.com/ulid/spec)
- Crockford 的 Base32 编码

## 未来增强

- 批量 API
- 单调生成器
- RFC3339 和 Unix 时间格式转换
- 其他 UUID 版本支持
- 性能优化
- Wasm 绑定
- CLI 扩展功能