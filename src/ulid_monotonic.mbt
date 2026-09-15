/// Monotonic ULID generator.
pub struct MonotonicUlidGenerator {
  mut last_timestamp : UInt64
  mut randomness : Bytes
  mut initialized : Bool
}

pub fn MonotonicUlidGenerator::new() -> MonotonicUlidGenerator {
  MonotonicUlidGenerator::{
    last_timestamp: 0,
    randomness: Bytes::from_array([for _ in 0..<10 => 0]),
    initialized: false,
  }
}

pub fn MonotonicUlidGenerator::generate(
  self : MonotonicUlidGenerator,
) -> Result[Ulid, UlidError] {
  self.generate_at(get_current_timestamp())
}

pub fn MonotonicUlidGenerator::generate_at(
  self : MonotonicUlidGenerator,
  timestamp_ms : UInt64,
) -> Result[Ulid, UlidError] {
  if timestamp_ms > 0xFFFFFFFFFFFF {
    return Result::Err(TimestampOverflow(timestamp_ms))
  }

  if !self.initialized || timestamp_ms > self.last_timestamp {
    self.last_timestamp = timestamp_ms
    self.randomness = generate_random_bytes()
    self.initialized = true
  } else {
    match increment_randomness(self.randomness) {
      Some(randomness) => self.randomness = randomness
      None => {
        if self.last_timestamp == 0xFFFFFFFFFFFF {
          return Result::Err(TimestampOverflow(self.last_timestamp))
        }
        self.last_timestamp += 1
        self.randomness = Bytes::from_array([for _ in 0..<10 => 0])
      }
    }
  }

  Ulid::from_parts(self.last_timestamp, self.randomness)
}

pub fn MonotonicUlidGenerator::generate_many(
  self : MonotonicUlidGenerator,
  count : Int,
) -> Result[Array[Ulid], UlidError] {
  if count < 0 {
    return Result::Err(InvalidLength(0, count))
  }
  let output : Array[Ulid] = []
  for _ in 0..<count {
    match self.generate() {
      Ok(value) => output.push(value)
      Err(error) => return Result::Err(error)
    }
  }
  Result::Ok(output)
}

fn increment_randomness(value : Bytes) -> Option[Bytes] {
  let output : Array[Byte] = [for index in 0..<10 => value[index]]
  let mut carry = 1
  for offset in 0..<10 {
    let index = 9 - offset
    let sum = output[index].to_int() + carry
    output[index] = (sum % 256).to_byte()
    carry = sum / 256
  }
  if carry == 1 {
    None
  } else {
    Some(Bytes::from_array(output))
  }
}