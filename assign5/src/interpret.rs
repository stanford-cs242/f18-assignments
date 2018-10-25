extern crate memory;

use ast::*;

// Print elements of config state, i.e. stack, locals, instrs
// Usage ex.:
//    print_config!(stack);
//    print_config!(instrs, stack);
//    etc
#[allow(unused_macros)]
macro_rules! print_config {
  ($x:ident) => (
    println!("{:?}", fmt_state!($x));
  );
  ($x:ident, $($y:ident),*) => (
    println!("{:?}", fmt_state!($x, $($y),*));
  );
}

// Print memory layout. Format is value@index.
// Usage: print_memory!(module.memory);
#[allow(unused_macros)]
macro_rules! print_memory {
  ($x:expr) => (
    println!("{:?}", fmt_state!($x));
  )
}

fn step(module: &mut WModule, config: WConfig) -> WConfig {
  use self::WInstr::*;

  let WConfig {mut locals, mut stack, mut instrs} = config;
  let instr = instrs.remove(0);

  let new_instr = match instr {

    Unreachable => Some(Trapping("Unreachable".to_string())),
    
    Const(n) => { stack.push(n); None },

    // YOUR CODE GOES HERE
    
    Binop(binop) => { unimplemented!(); }
    
    Relop(relop) => { unimplemented!(); }
    
    GetLocal(i) => { unimplemented!(); }
    
    SetLocal(i) => { unimplemented!(); }
    
    BrIf(label) => { unimplemented!(); }
    
    Return => { unimplemented!(); }
    
    Loop(instrs) => { unimplemented!(); }
    
    Block(instrs) => { unimplemented!(); }
    
    Label{continuation, stack: mut new_stack, instrs: new_instrs} => { unimplemented!(); }
    
    Call(i) => { unimplemented!(); }
    
    Frame(mut new_config) => { unimplemented!(); }
    
    Load => { unimplemented!(); }
    
    Store => { unimplemented!(); }
    
    Size => { unimplemented!(); }
    
    Grow => { unimplemented!(); }
    
    Returning(n) => { unimplemented!(); }
    
    Br(n) => { unimplemented!(); }
    
    Trapping(n) => unreachable!(),

    // END YOUR CODE

  };

  if let Some(ins) = new_instr {
    instrs.insert(0, ins);
  }

  WConfig {locals, stack, instrs}
}

pub fn interpret(mut module: WModule) -> Result<i32, String> {
  let mut config = WConfig {
    locals: vec![],
    stack: vec![],
    instrs: vec![WInstr::Call(0)]
  };

  while config.instrs.len() > 0 {
    if let WInstr::Trapping(ref err) = &config.instrs[0] {
      return Err(err.clone())
    }
    config = step(&mut module, config);
  }

  Ok(config.stack.pop().unwrap())
}


#[allow(unused_macros)]
macro_rules! fmt_state {
  ($x:ident) => (
    format!("{}: {:?}", stringify!($x), $x)
  );
  ($x:ident, $($y:ident),*) => (
    format!("{} | {}", fmt_state!($x), fmt_state!($($y),*))
  );
  ($x:expr) => {{
    let s: String = format!("{:?}", $x).chars().collect();
    let v = &s[8..s.len()-2];
    let mut r = format!("memory: [");
    let mut i = 0;
    for _c in v.chars() {
      if _c == ',' || _c == ' ' {
        continue;
      } else if _c != '0' {
        r = format!("{} {}@{} ", r, _c, i);
      }
      i += 1;
    }
    format!("{}]", r)
  }}
}
