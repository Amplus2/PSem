"use strict";var collwasm,collatz_steps,collatz_seq_impl,collatz_benford_impl;async function collatz_init(a){const b=await(await fetch(a)).arrayBuffer();collwasm=(await WebAssembly.instantiate(b)).instance.exports,collatz_steps=collwasm.collatz_steps,collatz_benford_impl=collwasm.collatz_benford,collatz_seq_impl=collwasm.collatz_seq}function range(a,b){if(b===void 0)return range(0,a-1);const c=[];for(var d=a;d<=b;d++)c.push(d);return c}function uses_mobile(){return-1!==navigator.userAgent.toLowerCase().indexOf("mobile")}function no_landscape(){return window.innerHeight>window.innerWidth}function collatz_batch_steps(a){const b=[];for(var c=0;c<a.length;c++)b.push(collatz_steps(a[c]));return b}function collatz_counts(a){const b=collatz_batch_steps(a);b.sort((c,a)=>c-a);const c=new Map;for(var d=0;d<b.length;d++){const e=b[d];c.has(e)?c.set(e,1+c.get(e)):c.set(e,1)}return c}function decode_utf8(b){return new TextDecoder("utf-8").decode(b)}function collatz_seq(a){const b=collatz_seq_impl(a,0);return decode_utf8(new Uint8Array(collwasm.memory.buffer,0,b))}function collatz_benford(a){const b=collatz_benford_impl(a,0),c=decode_utf8(new Uint8Array(collwasm.memory.buffer,0,b)),d=JSON.parse(c),e=new Map;for(let b=0;9>b;b++)e.set(b+1,d[b]);return e}
