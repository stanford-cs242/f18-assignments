#[derive(Debug, PartialEq, Eq, Clone)]
pub enum Sexp { List(Vec<Sexp>), Atom(String) }

impl Sexp {
  pub fn get_tag(&self) -> Option<String> {
    if let Sexp::List(ref l) = self {
      if let Sexp::Atom(ref s) = &l[0] {
        Some(s.clone())
      } else {
        None
      }
    } else {
      None
    }
  }

  pub fn has_tag<T: Into<String>>(&self, s: T) -> bool {
    if let Sexp::List(ref l) = self {
      l.len() > 0 && &l[0] == &Sexp::Atom(s.into())
    } else {
      false
    }
  }

  pub fn atom(&self) -> Option<String> {
    if let Sexp::Atom(ref s) = self {
      return Some(s.clone())
    } else {
      None
    }
  }

  pub fn iter(&self) -> Option<impl Iterator<Item=&Sexp>> {
    if let Sexp::List(ref l) = self {
      Some(l.iter())
    } else {
      None
    }
  }
}

pub trait FromSexp: Sized {
  fn from_sexp(sexp: &Sexp) -> Result<Self, String>;
}
