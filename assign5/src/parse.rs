extern crate memory;

use ast::*;
use nom::{is_alphanumeric, is_space};
use sexp::{Sexp, FromSexp};
use memory::VecMem;

impl FromSexp for WInstr {
  fn from_sexp(sexp: &Sexp) -> Result<Self, String> {
    let tag = sexp.get_tag().ok_or("Expr has no tag")?;

    let parse_first = || -> Result<i32, String> {
      let mut args = sexp.iter().unwrap();
      args.nth(1).ok_or("Missing arg")?
        .atom().ok_or("Arg not an atom")?
        .parse::<i32>().map_err(|e| e.to_string())
    };

    let parse_block = |sexp: &Sexp| -> Result<Vec<WInstr>, String> {
      let mut instrs = Vec::new();
      for s in sexp.iter().unwrap().skip(1) {
        instrs.push(WInstr::from_sexp(s)?);
      }
      Ok(instrs)
    };

    Ok(match tag.as_str() {

      "i32.const" => WInstr::Const(parse_first()?),

      "i32.add" => WInstr::Binop(WBinop::Add),
      "i32.sub" => WInstr::Binop(WBinop::Sub),
      "i32.mul" => WInstr::Binop(WBinop::Mul),
      "i32.div_s" => WInstr::Binop(WBinop::DivS),

      "i32.eq" => WInstr::Relop(WRelop::Eq),
      "i32.lt_s" => WInstr::Relop(WRelop::Lt),
      "i32.gt_s" => WInstr::Relop(WRelop::Gt),

      "get_local" => WInstr::GetLocal(parse_first()?),
      "set_local" => WInstr::SetLocal(parse_first()?),

      "i32.load" => WInstr::Load,
      "i32.store" => WInstr::Store,
      "memory.size" => WInstr::Size,
      "memory.grow" => WInstr::Grow,

      "unreachable" => WInstr::Unreachable,

      "block" => WInstr::Block(parse_block(sexp)?),
      "loop" => WInstr::Loop(parse_block(sexp)?),

      "br" => WInstr::Br(parse_first()?),
      "br_if" => WInstr::BrIf(parse_first()?),

      "return" => WInstr::Return,

      "call" => WInstr::Call(parse_first()?),

      t => { return Err(format!("Invalid expression tag {}", t)); }
    })
  }
}

impl FromSexp for WFunc {
  fn from_sexp(sexp: &Sexp) -> Result<Self, String> {
    if !sexp.has_tag("func") {
      return Err("Missing func tag".to_string())
    };

    let mut params = 0;
    let mut locals = 0;
    let mut _result = false;
    let mut body = Vec::new();
    for s in sexp.iter().unwrap().skip(1) {
      if s.has_tag("param") {
        params += 1;
      } else if s.has_tag("local") {
        locals += 1;
      } else if s.has_tag("result") {
        _result = true;
      } else {
        body.push(WInstr::from_sexp(s)?);
      }
    }

    Ok(WFunc { params, locals, body })
  }
}

impl FromSexp for VecMem {
  fn from_sexp(sexp: &Sexp) -> Result<Self, String> {
    if !sexp.has_tag("memory") {
      return Err("Missing memory tag".to_string());
    }

    let parse_first = || -> Result<i32, String> {
      let mut args = sexp.iter().unwrap();
      args.nth(1).ok_or("Missing arg")?
        .atom().ok_or("Arg not an atom")?
        .parse::<i32>().map_err(|e| e.to_string())
    };

    let npages = parse_first();
    match npages {
      Ok(n) => Ok(VecMem::new(n)),
      Err(e) => Err(e.to_string()),
    }
  }
}

impl FromSexp for WModule {
  fn from_sexp(sexp: &Sexp) -> Result<Self, String> {
    if !sexp.has_tag("module") {
      return Err("Missing module tag".to_string())
    };

    let mut funcs = Vec::new();
    let mut memory = None;
    for s in sexp.iter().unwrap().skip(1) {
      if s.has_tag("func") {
        funcs.push(WFunc::from_sexp(s)?);
      } else if s.has_tag("memory") {
        memory = Some(VecMem::from_sexp(s)?);
      } else {
        return Err("Invalid sexp in module".to_string());
      }
    }

    match memory {
      Some(m) => Ok(WModule { funcs, memory: Box::new(m) }),
      None => Ok(WModule { funcs, memory: Box::new(VecMem::new(0)) })
    }

  }

}

fn is_atom_char(c: char) -> bool {
  is_alphanumeric(c as u8) || c == '.' || c == '$' || c == '_'
}

named!(atom<&str, Sexp>,
       map!(take_while1!(is_atom_char), |s| Sexp::Atom(s.to_string())));

named!(whitespace<&str, &str>, take_while!(|c| is_space(c as u8) || c == '\n'));

named!(
  sexp<&str, Sexp>,
  alt!(
    map!(
      delimited!(
        char!('('),
        separated_list!(whitespace, sexp),
        char!(')')),
      |l: Vec<Sexp>| -> Sexp { Sexp::List(l) }) |
    atom));

pub fn parse(contents: &str) -> Result<WModule, String> {
  let nocomments = contents.split("\n").filter(|x| !x.contains(";;")).collect::<String>();
  let (_, sp) = sexp(&nocomments).map_err(|err| err.to_string())?;
  WModule::from_sexp(&sp)
}
