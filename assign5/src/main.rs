extern crate clap;
#[macro_use] extern crate nom;

extern crate memory;

mod sexp;
mod ast;
mod parse;
mod interpret;

use clap::{App, Arg};
use std::fs;

fn run(input: &str) -> Result<i32, String> {
  let ast = parse::parse(input)?;
  interpret::interpret(ast).map_err(|e| format!("{:?}", e))
}

fn main() {
  let matches = App::new("assign5")
    .arg(Arg::with_name("input").index(1).required(true))
    .get_matches();

  let file = matches.value_of("input").unwrap();
  let input = fs::read_to_string(file).expect("Couldn't read file");
  let result = run(&input);
  match result {
    Ok(n) => { println!("Success: {}", n); },
    Err(s) => { println!("Error: {}", s); }
  }
}
