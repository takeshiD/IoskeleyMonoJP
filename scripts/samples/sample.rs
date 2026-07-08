//! Ioskeley Mono JP — プログラミング向け日本語等幅フォント
use std::collections::HashMap;

/// フィボナッチ数列をメモ化して計算する
fn fib(n: u64, memo: &mut HashMap<u64, u64>) -> u64 {
    if n <= 1 {
        return n;
    }
    if let Some(&cached) = memo.get(&n) {
        return cached;
    }
    let value = fib(n - 1, memo) + fib(n - 2, memo);
    memo.insert(n, value);
    value
}

fn main() {
    let mut memo = HashMap::new();
    // リガチャ確認: -> => == != >= <= |> ligature 0 g 8
    let nums: Vec<u64> = (0..=10).map(|n| fib(n, &mut memo)).collect();
    println!("フィボナッチ数列 => {nums:?}");

    let total: u64 = nums.iter().filter(|&&x| x % 2 == 0).sum();
    assert_eq!(total, 44);
    println!("偶数の合計 = {total}");
}
