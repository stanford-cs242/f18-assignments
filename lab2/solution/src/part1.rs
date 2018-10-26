use std::{ptr, io};

fn password_checker(s: String) {
  let mut guesses = 0;
  loop {
    let mut buffer = String::new();
    if let Err(_) = io::stdin().read_line(&mut buffer) { return; }
    if buffer.len() == 0 { return; }

    /* BEGIN SOLUTION */
    if &buffer[0..(buffer.len()-1)] == &s {
      println!("You guessed it!");
      return;
    } else {
      println!("Guesses: {}", guesses + 1);
      guesses += 1;
    }
    /* END SOLUTION */
    /* BEGIN STARTER
    // If the buffer is "Password1" then print "You guessed it!" and return,
    // otherwise print the number of guesses so far.
    unimplemented!()
    END STARTER */
  }
}

fn add_n(v: Vec<i32>, n: i32) -> Vec<i32> {
  /* BEGIN SOLUTION */
  v.into_iter().map(|x| x + n).collect()
  /* END SOLUTION */
  /* BEGIN STARTER
  unimplemented!()
  END STARTER */
}

fn add_n_inplace(v: &mut Vec<i32>, n: i32) {
  /* BEGIN SOLUTION */
  for x in v.iter_mut() {
    *x = *x + n;
  }
  /* END SOLUTION */
  /* BEGIN STARTER
  unimplemented!()
  END STARTER */
}

fn reverse_clone<T: Clone>(v: &mut Vec<T>) {
    let n = v.len();
    for i in 0..n/2 {
        let x: T = v[i].clone();
        v[i] = v[n-i-1].clone();
        v[n-i-1] = x;
    }
}

fn reverse<T>(v: &mut Vec<T>) {
  /* BEGIN SOLUTION */
  let n = v.len();
  for i in 0..n/2 {
    /* BEGIN SOLUTION */
    unsafe {
      ptr::swap(&mut v[i] as *mut T, &mut v[n-i-1] as *mut T);
    }
    /* END SOLUTION */
    /* BEGIN STARTER
    unimplemented!()
    END STARTER */
  }
}

#[cfg(test)]
mod test {
  use super::*;

  #[test]
  fn test_password_checker() {
    //password_checker(String::from("Password1"));
  }

  #[test]
  fn test_add_n() {
    assert_eq!(add_n(vec![1], 2).pop().unwrap(), 3);
  }

  #[test]
  fn test_add_n_inplace() {
    let mut v = vec![1];
    add_n_inplace(&mut v, 2);
    assert_eq!(v[0], 3);
  }

  #[test]
  fn test_reverse() {
    let mut v = vec![1, 2, 3];
    reverse(&mut v);
    assert_eq!(v[0], 3);
  }
}