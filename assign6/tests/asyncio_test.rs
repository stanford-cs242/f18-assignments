extern crate take_mut;
extern crate lib;
extern crate tempfile;
use lib::asyncio::*;
use lib::executor::*;
use lib::future::*;
use lib::future_util::*;
use tempfile::NamedTempFile;
use std::io::Write;
use std::sync::{Mutex, Arc};


macro_rules! make_tmp {
  ($contents:expr) => {{
    let mut tmp = NamedTempFile::new().unwrap();
    {
      let f = tmp.as_file_mut();
      write!(f, $contents).unwrap();
      f.sync_all().unwrap();
    }
    tmp
  }}
}
#[test]
fn test_asyncio() {
  let tmp = make_tmp!("1.23");
  let fut = FileReader::new(tmp.path().to_path_buf());
  let mut exec = BlockingExecutor::new();
  exec.spawn(map(fut, |s| {
    assert_eq!(s.unwrap(), "1.23");
    ()
  }));
  exec.wait();
}
