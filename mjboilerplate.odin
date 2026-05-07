package mujoco
import "core:strings"

// Wrapper around mj.name2id() that adds some convience for Odin
name2id_safe :: proc(m: ^Model, type: tObj, name: string) -> (id: i32, ok: bool) {
	id = name2id(m, type, strings.clone_to_cstring(name, allocator = context.temp_allocator))
	ok = id >= 0
	return
}
