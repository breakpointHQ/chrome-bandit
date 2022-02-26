const tabs = new Map();

function attachDebugger(tabId) {
    chrome.debugger.attach({ tabId }, "1.2", function () {
        const commandParams = { type: "mousePressed", x: 1, y: 1, button: "left" };
        const timer = setInterval(function () {
            chrome.debugger.sendCommand({ tabId }, "Input.dispatchMouseEvent", commandParams);
            chrome.debugger.sendCommand({ tabId }, "Input.dispatchMouseEvent", commandParams);
        }, 100);
        tabs.set(tabId, timer);
    });
}

function queryTabs() {
    chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
        for (let tab of tabs) {
            if (tab.url.indexOf("http://localhost") === 0) {
                attachDebugger(tab.id);
            }
        }
    });
}

chrome.tabs.onRemoved.addListener(function (tabId) {
    if (tabs.get(tabId)) {
        clearInterval(tabs.get(tabId));
        tabs.delete(tabId);
    }
});

queryTabs();
chrome.tabs.onUpdated.addListener(queryTabs);
