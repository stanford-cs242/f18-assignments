#![allow(dead_code, non_camel_case_types, non_snake_case, non_upper_case_globals)]
mod lauxlib;

use lauxlib::*;
use std::ffi::{CString, CStr};
use std::os::raw::{c_char, c_int};
use std::ptr;

unsafe fn lua_pushcfunction(L: *mut lua_State, f: lua_CFunction) {
	lua_pushcclosure(L, f, 0);
}

unsafe fn luaL_checkstring(L: *mut lua_State, n: c_int) -> *const c_char {
  luaL_checklstring(L, n, ptr::null::<usize>() as *mut usize)
}

fn cstr<T: Into<String>>(s: T) -> *const c_char {
  CString::new(s.into()).unwrap().into_raw()
}

unsafe extern "C" fn stringmatch(L: *mut lua_State) -> c_int {
  unimplemented!()
}

#[no_mangle]
pub unsafe extern "C" fn luaopen_stringmatch(L: *mut lua_State) -> isize {
  lua_createtable(L, 1, 0);
  lua_pushstring(L, cstr("match"));
  lua_pushcfunction(L, Some(stringmatch));
  lua_settable(L, -3);
  return 1;
}
