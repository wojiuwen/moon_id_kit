///| 
/// ULID 核心实现

///|
pub struct Ulid {
  timestamp : UInt64
  randomness : Bytes
}

///|
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

pub enum IdError {
  InvalidSize(Int)
  InvalidIdLength(Int, Int)
  InvalidIdCharacter(Int, Char)
  InvalidIdFormat
  IdTimestampOutOfRange(UInt64)
}

pub fn IdError::message(self : IdError) -> String {
  match self {
    InvalidSize(size) => "Invalid ID size: \{size}"
    InvalidIdLength(expected, actual) =>
      "Invalid ID length: expected \{expected}, got \{actual}"
    InvalidIdCharacter(position, character) =>
      "Invalid ID character at position \{position}: '\{character}'"
    InvalidIdFormat => "Invalid ID format"
    IdTimestampOutOfRange(value) => "ID timestamp out of range: \{value}"
  }
}

pub fn IdError::code(self : IdError) -> String {
  match self {
    InvalidSize(_) => "INVALID_SIZE"
    InvalidIdLength(_, _) => "INVALID_ID_LENGTH"
    InvalidIdCharacter(_, _) => "INVALID_ID_CHARACTER"
    InvalidIdFormat => "INVALID_ID_FORMAT"
    IdTimestampOutOfRange(_) => "ID_TIMESTAMP_OUT_OF_RANGE"
  }
}

///|
pub fn UlidError::message(self : UlidError) -> String {
  match self {
    InvalidLength(expected, actual) =>
      "Invalid length: expected \{expected}, got \{actual}"
    InvalidCharacter(position, character) =>
      "Invalid character at position \{position}: '\{character}'"
    InvalidLeadingValue => "Invalid leading value"
    TimestampOverflow(value) => "Timestamp overflow: \{value}"
    InvalidByteLength(expected, actual) =>
      "Invalid byte length: expected \{expected}, got \{actual}"
    InvalidUuidFormat => "Invalid UUID format"
    UnsupportedUuidVersion(version) => "Unsupported UUID version: \{version}"
    UnsupportedUuidVariant => "Unsupported UUID variant"
    UuidTimestampOutOfRange(value) => "UUID timestamp out of range: \{value}"
  }
}

///|
pub fn UlidError::code(self : UlidError) -> String {
  match self {
    InvalidLength(_, _) => "INVALID_LENGTH"
    InvalidCharacter(_, _) => "INVALID_CHARACTER"
    InvalidLeadingValue => "INVALID_LEADING_VALUE"
    TimestampOverflow(_) => "TIMESTAMP_OVERFLOW"
    InvalidByteLength(_, _) => "INVALID_BYTE_LENGTH"
    InvalidUuidFormat => "INVALID_UUID_FORMAT"
    UnsupportedUuidVersion(_) => "UNSUPPORTED_UUID_VERSION"
    UnsupportedUuidVariant => "UNSUPPORTED_UUID_VARIANT"
    UuidTimestampOutOfRange(_) => "UUID_TIMESTAMP_OUT_OF_RANGE"
  }
}

///|
pub fn Ulid::timestamp_ms(self : Ulid) -> UInt64 {
  self.timestamp
}

///|
pub fn Ulid::timestamp_seconds(self : Ulid) -> UInt64 {
  self.timestamp / 1000
}
