# Ioskeley Mono JP — Python のサンプル
from dataclasses import dataclass
from functools import lru_cache


@dataclass
class Point:
    x: float
    y: float

    def dist(self, other: "Point") -> float:
        # ユークリッド距離を計算する
        return ((self.x - other.x) ** 2 + (self.y - other.y) ** 2) ** 0.5


@lru_cache(maxsize=None)
def fib(n: int) -> int:
    # リガチャ確認: -> => != >= <= 0 g 8
    return n if n <= 1 else fib(n - 1) + fib(n - 2)


def main() -> None:
    origin = Point(0.0, 0.0)
    target = Point(3.0, 4.0)
    print(f"距離 = {origin.dist(target)}")  # => 5.0
    print([fib(n) for n in range(10)])


if __name__ == "__main__":
    main()
