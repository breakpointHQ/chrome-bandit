const tabs = new Map();

chrome.tabs.onUpdated.addListener(function (tabId) {
    chrome.debugger.attach({ tabId }, "1.2", function () {
        const commandParams = { type: "mousePressed", x: 1, y: 1, button: "left" };
        const timer = setInterval(function () {
            chrome.debugger.sendCommand({ tabId }, "Input.dispatchMouseEvent", commandParams);
            chrome.debugger.sendCommand({ tabId }, "Input.dispatchMouseEvent", commandParams);
        }, 100);
        tabs.set(tabId, timer);
    });
});

chrome.tabs.onRemoved.addListener(function (tabId) {
    if (tabs.get(tabId)) {
        clearInterval(tabs.get(tabId));
        tabs.delete(tabId);
    }
});