#include <iostream>
#include <string_view>

int main() {
  constexpr std::string_view msg = "Hello, World!";
  std::cout << msg << '\n';
  return 0;
}
