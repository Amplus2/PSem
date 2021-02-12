const asmArgs = {};

function range(start, end) {
    var result = [];
    if(end === undefined)
        for (var i = 0; i < start; i++)
            result.push(i);
    else
        for (var i = start; i <= end; i++)
            result.push(i);
    return result;
}


async function get_wasm_exports(path) {
    return (await WebAssembly.instantiate(await (await fetch(path)).arrayBuffer())).instance.exports;
}

async function collatz_steps(path, range) {
    const result = [];
    const exports = await get_wasm_exports(path);
    for(var i = 0; i < range.length; i++) result.push(exports.collatz_steps(BigInt(range[i])));
    return result;
}

async function collatz_steps_js(range) {
    function steps(input) {
        if (input < 1) return -1;
        var steps = 0;
        while (true) {
            if(input == 1) return steps;
            input = input % 2 == 1 ? 3 * input + 1 : input / 2;
            steps++;
        }
    }
    const result = [];
    for(var i = 0; i < range.length; i++) result.push(steps(range[i]));
    return result;
}