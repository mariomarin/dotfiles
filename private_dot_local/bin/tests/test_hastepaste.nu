use std/assert

source ../executable_hastepaste

def "test normalize-url plain domain" [] {
  assert equal (normalize-url "paste.example.com") "https://paste.example.com"
}

def "test normalize-url with trailing slash" [] {
  assert equal (normalize-url "paste.example.com/") "https://paste.example.com"
}

def "test normalize-url with https" [] {
  assert equal (normalize-url "https://paste.example.com") "https://paste.example.com"
}

def "test normalize-url with https and trailing slash" [] {
  assert equal (normalize-url "https://paste.example.com/") "https://paste.example.com"
}

def "test normalize-url with http" [] {
  assert equal (normalize-url "http://paste.example.com") "http://paste.example.com"
}

def "test normalize-url with whitespace" [] {
  assert equal (normalize-url "  paste.example.com  ") "https://paste.example.com"
}

def "test parse-haste-response valid" [] {
  let result = (parse-haste-response '{"key":"abc123"}')
  assert equal $result.ok true
  assert equal $result.value "abc123"
}

def "test parse-haste-response with extra fields" [] {
  let result = (parse-haste-response '{"key":"xyz","other":"val"}')
  assert equal $result.ok true
  assert equal $result.value "xyz"
}

def "test parse-haste-response empty body" [] {
  let result = (parse-haste-response "")
  assert equal $result.ok false
  assert ($result.error | str contains "empty")
}

def "test parse-haste-response invalid json" [] {
  let result = (parse-haste-response "not json")
  assert equal $result.ok false
  assert ($result.error | str contains "invalid JSON")
}

def "test parse-haste-response no key field" [] {
  let result = (parse-haste-response '{"id":"abc"}')
  assert equal $result.ok false
  assert ($result.error | str contains "no key")
}

def "test build-paste-url without extension" [] {
  assert equal (build-paste-url "https://paste.example.com" "abc123" "") "https://paste.example.com/abc123"
}

def "test build-paste-url with extension" [] {
  assert equal (build-paste-url "https://paste.example.com" "abc123" "py") "https://paste.example.com/abc123.py"
}

def "test strip-ansi removes codes" [] {
  let input = $"\e[31mred text\e[0m normal"
  assert equal (strip-ansi $input) "red text normal"
}

def "test strip-ansi plain text unchanged" [] {
  assert equal (strip-ansi "hello world") "hello world"
}
