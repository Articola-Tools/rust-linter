// This file is intentionally written to violate strict clippy lints and
// thailint linters (blocking-async, clone-abuse, unwrap-abuse).
// It is a test fixture for the `rust-linter` Docker image and is expected to
// fail `cargo clippy --all-targets` running in strict mode (all clippy lints
// enabled, `clippy::nursery` excluded, any warning denied) and/or thailint
// linters running with strict configuration.

/// This function does something useful.
pub fn DoSomething() -> i32 {
    return 42;
}

/// This function panics for demonstration purposes.
pub fn something_that_panics() {
    panic!("intentional panic for test");
}

/// This function computes a value.
pub fn compute_value() -> i32 {
    42
}

/// This async function calls blocking file I/O, violating the
/// `blocking-async.fs-in-async` thailint rule.
pub async fn read_config_blocking() -> String {
    std::fs::read_to_string("config.toml").unwrap()
}

/// This function clones inside a loop, violating the
/// `clone-abuse.clone-in-loop` thailint rule.  It also contains a chained
/// `.clone().clone()`, violating the `clone-abuse.clone-chain` rule.
pub fn clone_abuse_example(names: &[String]) -> Vec<String> {
    let mut result = Vec::new();
    for name in names {
        let cloned = name.clone().clone();
        result.push(cloned);
    }
    result
}

fn main() {
    let unused_variable = 5;
    let x = 5;
    let y = 10;

    println!("x = {}, y = {}", x, y);

    dbg!(x);

    let result: Result<i32, &str> = Ok(42);
    let value = result.unwrap();
    println!("value = {}", value);

    let result2: Result<i32, &str> = Err("error");
    let _value2 = result2.expect("should not fail");

    let opt = Some(5);
    match opt {
        Some(v) => println!("v = {}", v),
        None => {}
    }

    let _ = compute_value();
    let _ = DoSomething();
    something_that_panics();
}
