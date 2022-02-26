# Chrome Bandit

Programmatically extract saved passwords from Chromium based browsers.

<p align="center">
    <img src="./resources/images/logo.svg" width="200" />
</p>

## Browser Support

| [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/edge/edge_48x48.png" alt="IE / Edge" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Edge | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/chrome/chrome_48x48.png" alt="Chrome" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Chrome | [<img src="https://raw.githubusercontent.com/alrra/browser-logos/master/src/opera/opera_48x48.png" alt="Opera" width="24px" height="24px" />](http://godban.github.io/browsers-support-badges/)<br/>Opera |
| --------- | --------- | --------- |
| macOS only | macOS only | macOS only

## Quick start
```
brew install breakpointhq/chrome-bandit/chrome-bandit
```

## Usage

```sh
chrome-bandit <command>

Useage:

chrome-bandit list                     list browser passwords                 
chrome-bandit decrypt                  decrypt a given password               
chrome-bandit <command> -help          quick help on <command>
```

### List credentials

```sh
Usage: chrome-bandit list [options]
    -u, --url <url>                  only show credentials where the origin url match <url>
    -f, --format <format>            set the output format: text, json
    -l, --login_data <path>          set the "Login Data" file path
        --chrome
        --opera
        --edge
    -v, --verbose
```

```sh
chrome-bandit list --opera
+----------+----------------------------+--------------------+
| ID       | URL                        | Username           |
+----------+----------------------------+--------------------+
| 1        | https://paypal.com/        | example@gmail.com  |
| 2        | https://github.com/session | masasron           |
+----------+----------------------------+--------------------+
```

```sh
chrome-bandit list --chrome --url github
+----------+----------------------------+--------------------+
| ID       | URL                        | Username           |
+----------+----------------------------+--------------------+
| 235      | https://github.com/session | masasron           |
+----------+----------------------------+--------------------+
```

### Decrypt a password

```sh
Usage: chrome-bandit decrypt [options]
    -x, --port <port>                set HTTP server port
    -f, --format <format>            set the output format: text, json
    -l, --login_data <path>          set the "Login Data" file path
    -b <name>,                       set the browser process name
        --browser_process_name
    -p <path>,                       set the browser executable path
        --browser_executable_path
    -i, --id <id>                    decrypt the password for a given site id
    -u, --url <url>                  decrypt the password for the first match of a given url
        --chrome
        --opera
        --edge
    -v, --verbose
```

```sh
chrome-bandit decrypt --chrome --url paypal
+-------------------------+---------------------------+-----------------+
| URL                     | Username                  | Password        |
+-------------------------+---------------------------+-----------------+
| https://www.paypal.com/ | example@gmail.com         | qwerty          |
+-------------------------+---------------------------+-----------------+
```

## Background

This project started as a proof of concept to demonstrate how saved passwords on Google Chrome and other Chromium-based browsers can easily be stolen by malicious macOS programs. I've decided to turn it into a more robust tool for red teams targeting macOS.

The way passwords are stored on Windows and macOS is different.

On Windows, Chrome uses the Data Protection API (DPAPI) to bind your passwords to your user account. The passwords are store on disk, encrypted with a key **accessible only to processes running as the same logged on user.**

On macOS, Chrome is storing the credentials in a “Login Data” file located at the Chrome users profile directory. The passwords are stored encrypted on disk, the encryption key is then stored in the user’s Keychain.

macOS Keychain uses [Access Control Lists](https://developer.apple.com/documentation/security/keychain_services/access_control_lists) that control which apps have access to Keychain items in macOS. This makes it way harder for malicious programs to programmatically steal saved passwords.

## Legal Disclaimer
Usage of this code for attacking targets without prior mutual consent is illegal. It's the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program. Only use for educational purposes.

<p align="right">
    <img src="./resources/images/cactus.svg" width="128" />
</p>
