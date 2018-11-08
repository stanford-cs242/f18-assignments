extern crate rand;

pub mod session_bug;
//mod counterex;
pub mod session;
pub mod tcp;
pub mod atm;

#[cfg(test)]
mod test {
  use session::*;
  use session::NOISY;
  use std::sync::atomic::Ordering;
  use rand;
  use rand::Rng;
  use tcp::*;
  use std::marker::PhantomData;
  use std::sync::mpsc::channel;
  use std::thread;

  fn gen_bufs() -> Vec<Buffer> {
    let mut bufs: Vec<Buffer> = Vec::new();
    let mut rng = rand::thread_rng();
    for _ in 0usize..20 {
      let buf: Buffer = vec![0; rng.gen_range(1, 10)];
      let buf: Buffer = buf.into_iter().map(|x: u8| rng.gen()).collect();
      bufs.push(buf);
    }
    bufs
  }

  #[test]
  fn test_basic() {
    let bufs = gen_bufs();
    let bufs_copy = bufs.clone();
    let (s, c): ((Chan<(), TCPServer>), (Chan<(), TCPClient>)) = Chan::new();
    let thread = thread::spawn(move || { tcp_client(c, bufs); });

    let recvd = tcp_server(s);
    let res = thread.join();

    assert_eq!(recvd, bufs_copy);
  }

  #[test]
  fn test_lossy() {
    let bufs = gen_bufs();
    let bufs_copy = bufs.clone();

    NOISY.with(|noisy| {
      noisy.store(true, Ordering::SeqCst);
    });

    let (s, c): ((Chan<(), TCPServer>), (Chan<(), TCPClient>)) = Chan::new();
    let thread = thread::spawn(move || { tcp_client(c, bufs); });

    let recvd = tcp_server(s);
    let res = thread.join();

    assert_eq!(recvd, bufs_copy);
  }
}
