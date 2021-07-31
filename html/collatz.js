var collwasm;
var collatz_steps;
var collatz_seq_impl;

async function collatz_init(path) {
    const cum = await (await fetch(path)).arrayBuffer();
    collwasm = (await WebAssembly.instantiate(cum)).instance.exports;
    collatz_steps = collwasm.collatz_steps;
    collatz_seq_impl = collwasm.collatz_seq;
}

function range(start, end) {
    if (end === undefined)
        return range(0, start-1);
    const result = [];
    for (var i = start; i <= end; i++)
        result.push(i);
    return result;
}

function uses_mobile() {
    return navigator.userAgent.toLowerCase().indexOf("mobile") !== -1;
}

function no_landscape() {
    return window.innerHeight > window.innerWidth;
}

function collatz_batch_steps(range) {
    const result = [];
    for (var i = 0; i < range.length; i++)
        result.push(collatz_steps(range[i]));
    return result;
}

function collatz_counts(range) {
    const collatz_nums = collatz_batch_steps(range);
    collatz_nums.sort((a, b) => a - b);
    const result = new Map();
    for (var i = 0; i < collatz_nums.length; i++) {
        const a = collatz_nums[i];
        if (!result.has(a)) result.set(a, 1);
        else result.set(a, 1 + result.get(a));
    }
    return result;
}

function decode_utf8(a) {
    return new TextDecoder("utf-8").decode(a);
}

function collatz_seq(n) {
    const len = collatz_seq_impl(n, 0);
    return decode_utf8(new Uint8Array(collwasm.memory.buffer, 0, len));
}
