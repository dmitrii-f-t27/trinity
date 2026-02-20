// WASM Memory Buffers
// align(16) is required for efficient WASM/Host data transfer

var global_buffer: [65536]u8 align(16) = undefined;
var f64_buffer: [8192]f64 align(16) = undefined;

pub fn get_global_buffer() []u8 {
    return &global_buffer;
}

pub fn get_f64_buffer() []f64 {
    return &f64_buffer;
}

export fn get_global_buffer_ptr() [*]u8 {
    return &global_buffer;
}

export fn get_f64_buffer_ptr() [*]f64 {
    return &f64_buffer;
}
