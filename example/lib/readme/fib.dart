// An expensive but pretty
// recursive implementation
int fibonacci(int n) {
  if (n <= 1) return n;
  return fibonacci(n - 1)
    + fibonacci(n - 2);
}

void main() {
  print("Fibonacci sequence:");
  for (var n = 0; n < 10; n++)
    print(fibonacci(n));
}
