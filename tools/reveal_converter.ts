#!/bin/env -S deno run --allow-net

import * as deno_dom from "https://deno.land/x/deno_dom/deno-dom-wasm.ts";

async function fetch_image(url:string) {
    const result = await fetch(url);
    return new Uint8Array(await result.arrayBuffer());
}

function u8_to_base64(u8:Uint8Array) {
    var result = '';
    for (let i = 0; i < u8.length; i++) {
        result += String.fromCharCode(u8[i]);
    }
    return btoa(result);
}

async function traverse_html(html:string) {
    const document = new deno_dom.DOMParser().parseFromString(html, 'text/html');

    const imgs = document!.getElementsByTagName('img');
    for (let i = 0; i < imgs.length; i++) {
        const data_src = imgs[i].getAttribute('data-src');
        
        if (data_src !== null) {
            const b64 = u8_to_base64(await fetch_image(data_src));
            const str = 'data:image;base64,' + b64;
            imgs[i].removeAttribute('data-src');
            imgs[i].setAttribute('src', str);
        }
    }

    return document!.textContent;
}


if (Deno.args.length <= 1) {
    console.log('missing argument');
    Deno.exit(1);
}

const html = await Deno.readFile(Deno.args[0]);
console.log(html)