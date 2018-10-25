extern crate memory;

use memory::{WMemory, VecMem};

const PAGE_SIZE: i32 = 4096;


#[test]
fn test_load_store() {
    let mut mem = VecMem::new(1);
    assert!(mem.store(0, 5));
    assert!(mem.store(3909, 9));
    assert!(!mem.store(5000, 1));
    assert_eq!(mem.load(3909).unwrap(), 9);
    assert_eq!(mem.load(8).unwrap(), 0);
    assert_eq!(mem.load(5000), None);
}

#[test]
fn test_grow_size() {
    let mut mem = VecMem::new(1);
    assert_eq!(mem.size(), PAGE_SIZE);
    mem.grow();
    assert_eq!(mem.size(), 2 * PAGE_SIZE);
}
