extern crate rand;

use session::*;
use std::collections::{HashSet, HashMap};

pub struct Syn;
pub struct SynAck;
pub struct Ack;
pub struct Fin;

pub type TCPHandshake<TCPRecv> = ();

pub type TCPRecv<TCPClose> = ();

pub type TCPClose = ();

pub type TCPServer = TCPHandshake<TCPRecv<TCPClose>>;

pub type TCPClient = <TCPServer as HasDual>::Dual;

pub fn tcp_server(c: Chan<(), TCPServer>) -> Vec<Buffer> {
  unimplemented!();
}

pub fn tcp_client(c: Chan<(), TCPClient>, bufs: Vec<Buffer>) {
  unimplemented!();
}
