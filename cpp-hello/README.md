# C++17 Hello World

## 编译

```bash
# GCC / Clang (Linux / macOS / MinGW)
g++ -std=c++17 -o hello main.cpp

# 或
clang++ -std=c++17 -o hello main.cpp
```

Windows (MSVC) 命令行：

```cmd
cl /std:c++17 /EHsc main.cpp
```

生成 `main.exe`。

## 运行

```bash
./hello
```

Windows: `main.exe` 或 `hello.exe`（取决于上面使用的输出名）。

## 编译器要求

- GCC 7+
- Clang 5+
- MSVC 2017+ (Visual Studio 2017 及以上)

本示例使用 C++17 的 `std::string_view`。
