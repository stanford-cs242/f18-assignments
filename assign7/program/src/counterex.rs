use session_bug::*;

fn sample_bug() {
  // this is only a bug **if** you comment out the Chan<Close> implementation
  // on line 63. you should get a compile error
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

#[cfg(test)]
mod tests {
  #[test]
  fn bug1() {
    super::bug1();
  }

  #[test]
  fn bug2() {
    super::bug2();
  }

  #[test]
  fn bug3() {
    super::bug3();
  }
}
