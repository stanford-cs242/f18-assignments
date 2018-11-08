use session_bug::*;

fn sample_bug() {
  // this is only a bug **if** you comment out the Chan<Close> implementation
  // on line 63 of session_bug.rs. you should get a compile error
  type Server = Close;
  let (c, _): (Chan<Server>, _) = Chan::new();
  c.close();
}

pub fn bug1() {
  unimplemented!()
}

pub fn bug2() {
  unimplemented!()
}

pub fn bug3() {
  unimplemented!()
}
