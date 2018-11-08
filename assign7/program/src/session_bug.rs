use std::marker::PhantomData;
use std::sync::mpsc::{Sender, Receiver};
use std::marker;
use std::mem::transmute;
use std::sync::mpsc::channel;

pub struct Send<T, S>(PhantomData<(T, S)>);
pub struct Recv<T, S>(PhantomData<(T, S)>);
pub struct Offer<Left, Right>(PhantomData<(Left, Right)>);
pub struct Choose<Left, Right>(PhantomData<(Left, Right)>);
pub struct Close; // equivalent to epsilon

pub trait HasDual {
  type Dual;
}

impl HasDual for Close {
  type Dual = Close;
}

impl<T, S> HasDual for Send<T, S> where S: HasDual {
  type Dual = Recv<T, S::Dual>;
}

impl<T, S> HasDual for Recv<T, S> where S: HasDual {
  type Dual = Recv<T, S::Dual>;
}

impl<Left, Right> HasDual for Choose<Left, Right>
where Left: HasDual, Right: HasDual {
  type Dual = Offer<Left::Dual, Right::Dual>;
}

impl<Left, Right> HasDual for Offer<Left, Right>
where Left: HasDual, Right: HasDual {
  type Dual = Choose<Left::Dual, Right::Dual>;
}

pub struct Chan<S> {
  sender: Sender<Box<u8>>,
  receiver: Receiver<Box<u8>>,
  _data: PhantomData<S>,
}

impl<S> Chan<S> {
  unsafe fn write<T>(&self, x: T)
  where
    T: marker::Send + 'static,
  {
    let sender: &Sender<Box<T>> = transmute(&self.sender);
    sender.send(Box::new(x)).unwrap();
  }

  unsafe fn read<T>(&self) -> T
  where
    T: marker::Send + 'static,
  {
    let receiver: &Receiver<Box<T>> = transmute(&self.receiver);
    *receiver.recv().unwrap()
  }
}

impl Chan<Close> {
  pub fn close(self) {}
}

impl<T, S> Chan<Send<T, S>>
where
  T: marker::Send + 'static,
{
  pub fn send(self, x: T) -> Chan<Send<T, S>> {
    unsafe {
      self.write(x);
      transmute(self)
    }
  }
}

impl<T, S> Chan<Recv<T, S>>
where
  T: marker::Send + 'static,
{
  pub fn recv(self) -> (Chan<S>, T) {
    unsafe {
      let a = self.read();
      (transmute(self), a)
    }
  }
}

impl<Left, Right> Chan<Choose<Left, Right>> {
  pub fn left(self) -> Chan<Left> {
    unsafe {
      self.write(false);
      transmute(self)
    }
  }

  pub fn right(self) -> Chan<Right> {
    unsafe {
      self.write(true);
      transmute(self)
    }
  }
}

pub enum Branch<L, R> {
  Left(L),
  Right(R),
}

impl<Left, Right> Chan<Offer<Left, Right>> {
  pub fn offer(self) -> Branch<Chan<Left>, Chan<Right>> {
    unsafe {
      if self.read() {
        Branch::Left(transmute(self))
      } else {
        Branch::Right(transmute(self))
      }
    }
  }
}

impl<S> Chan<S> where S: HasDual {
  pub fn new() -> (Chan<S>, Chan<S::Dual>) {
    let (sender1, receiver1) = channel();
    let (sender2, receiver2) = channel();
    let c1 = Chan {
      sender: sender1,
      receiver: receiver2,
      _data: PhantomData,
    };
    let c2 = Chan {
      sender: sender2,
      receiver: receiver1,
      _data: PhantomData,
    };
    (c1, c2)
  }
}
