fn random_bytes(size : Int) -> Bytes {
  let random = @random.Rand::new()
  Bytes::from_array([
    for _ in 0..<size => random.uint64().to_byte()
  ])
}