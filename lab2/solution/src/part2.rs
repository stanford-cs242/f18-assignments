use std::collections::{HashMap, HashSet};

struct Event {
  pub name: String,
  pub month: u8,
  pub day: u8,
  pub year: u32
}

/* You need to complete two functions in this implementation
 * has_conflict() and update_event(). Note that the argument(s) and
 * return values for these two functions are missing below.
 * You can refer to tests for more information. */
impl Event {
  pub fn new(name: String, month: u8, day: u8, year: u32) -> Event {
    Event { name, month, day, year }
  }

  /* This function checks if two events are one the same date */
  /* BEGIN SOLUTION */
  pub fn has_conflict(&self, other: &Event) -> bool {
    self.month == other.month && self.day == other.day && self.year == other.year
  }
  /* END SOLUTION */
  /* BEGIN STARTER
  pub fn has_conflict() {
    // Your code!
  }
  END STARTER */

  /* This function shifts the date of an event by one day.
   * You can assume that the date is not on the last day
   * of a month */
  /* BEGIN SOLUTION */
  pub fn update_event(&mut self) {
    self.day += 1;
  }
  /* END SOLUTION */
  /* BEGIN STARTER
  pub fn update_event() {
    // Your code!
  }
  END STARTER */
}

#[derive(Debug, Clone, Eq, PartialEq)]
struct Trie {
  chr: char,
  has: bool,
  children: Vec<Trie>,
}

/* ["a", "cc", "ab"] =>
   {'\0', false, [
     {'a', true, [{'b', true, []}]},
     {'c', false, [{'c', true, []}]}
   ]}
*/

impl Trie {
  pub fn new(strs: &Vec<&str>) -> Trie {
    Trie::build(strs, '\0')
  }

  fn build(strs: &Vec<&str>, chr: char) -> Trie {
    /* BEGIN SOLUTION */
    let fc = strs.iter().filter_map(|s| s.chars().next())
      .collect::<HashSet<_>>();
    Trie {
      chr,
      has: strs.iter().filter(|s| s.len() == 0).count() > 0,
      children:
        fc.into_iter().map(|c| {
          Trie::build(
            &strs.iter().filter(|s| s.chars().next().unwrap() == c).
              map(|s|
                  if s.len() > 1 { &s[1..] }
                  else { "" }).collect::<Vec<_>>(), c)
        }).collect::<Vec<_>>()
    }
    /* END SOLUTION */
    /* BEGIN STARTER
    unimplemented!()
    END STARTER */
  }

  pub fn contains(&self, s: &str) -> bool {
    /* BEGIN SOLUTION */
    if s.len() == 0 { return self.has; }
    let chr = s.chars().next().unwrap();
    for child in self.children.iter() {
      if child.chr == chr {
        return child.contains(&s[1..]);
      }
    }
    return false;
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
  fn test_event() {
    let event1 = Event::new("Pac-12 Championship".into(), 12, 1, 2017);
    let mut event2 = Event::new("Group Project Meeting".into(), 12, 1, 2017);
    assert!(event1.has_conflict(&event2));

    event2.update_event();
    assert_eq!(event2.day, 2);
  }

  #[test]
  fn test_trie() {
    let trie = Trie::new(&vec!["b", "ab"]);
    assert_eq!(trie.contains("ab"), true);
    assert_eq!(trie.contains("ac"), false);
    assert_eq!(trie.contains("a"), false);
    assert_eq!(trie.contains("b"), true);
  }
}