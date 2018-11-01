extern crate lib;
use lib::executor::*;
use lib::future::*;
use lib::future_util::*;
use std::sync::{Mutex, Arc};

fn test_executor<T: Executor>(mut exec: T) {
  for _ in 0..100 {
    let f1 = immediate(5);
    let f2 = immediate(6);
    let f3 = join(f1, f2);
    exec.spawn(map(f3, |n| {
      assert_eq!(n, (5, 6));
      ()
    }));
  }
  exec.wait();
}

#[test]
fn blocking() {
  test_executor(BlockingExecutor::new());
}

#[test]
fn singlethread() {
  test_executor(SingleThreadExecutor::new());
}

#[test]
fn multithread() {
  test_executor(MultiThreadExecutor::new(4));
}