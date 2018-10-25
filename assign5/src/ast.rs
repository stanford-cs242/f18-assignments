extern crate memory;

use memory::WMemory;

#[derive(Debug, PartialEq, Clone, Eq)]
pub enum WBinop { Add, Sub, Mul, DivS }

#[derive(Debug, PartialEq, Clone, Eq)]
pub enum WRelop { Eq, Lt, Gt }

#[derive(Debug, PartialEq, Clone, Eq)]
pub enum WInstr {
  // Core instructions
  Const(i32),
  Binop(WBinop),
  Relop(WRelop),
  GetLocal(i32),
  SetLocal(i32),
  Load,
  Store,
  Size,
  Grow,
  Unreachable,
  Block(Vec<WInstr>),
  Loop(Vec<WInstr>),
  Br(i32),
  BrIf(i32),
  Return,
  Call(i32),

  // Administrative instructions
  Label{continuation: Box<Option<WInstr>>, stack: WStack, instrs: Vec<WInstr>},
  Frame(WConfig),
  Returning(i32),
  Trapping(String),
}

#[derive(Debug, Clone)]
pub struct WFunc {
  pub params: i32,
  pub locals: i32,
  pub body: Vec<WInstr>
}

#[derive(Debug)]
pub struct WModule {
  pub funcs: Vec<WFunc>,
  pub memory: Box<WMemory>
}

// Runtime constructs
pub type WStack = Vec<i32>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct WConfig {
  pub locals: Vec<i32>,
  pub stack: WStack,
  pub instrs: Vec<WInstr>
}
