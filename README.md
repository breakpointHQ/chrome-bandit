# Chrome Bandit

Programmatically extract saved passwords from Chromium based browsers.
Currently Bandit supports Google Chrome, Microsoft Edge, and Opera on macOS.

<center>
    <img src="./resources/images/logo.svg" width="128" />
</center>

## Usage

```
chrome-bandit <command>

Useage:

chrome-bandit list                     list browser passwords                 
chrome-bandit decrypt                  decrypt a given password               
chrome-bandit <command> -help          quick help on <command>
```

### List

```
Usage: chrome-bandit list [options]
    -u, --url <url>                  only show passwords that match <url>
    -f, --format <format>            set the output format: text, json
    -l, --login_data <path>          set the Login Data file to <path>
        --chrome
        --opera
        --edge
    -v, --verbose
```

### Decrypt

```
Usage: chrome-bandit decrypt [options]
    -x, --port <port>                set server HTTP port
    -f, --format <format>            set the output format: text, json
    -l, --login_data <path>          set the "Login Data" file path to <path>
    -b <name>,                       set the browser process name to <name>
        --browser_process_name
    -p <path>,                       set the browser executable path to <path>
        --browser_executable_path
    -i, --id <id>                    decrypt the password for site <id>
    -u, --url <url>                  decrypt the password for the first match for <url>
        --chrome
        --opera
        --edge
    -v, --verbose
```

## Background

The way passwords are stored on Windows and macOS is different.

On Windows, Chrome uses the Data Protection API (DPAPI) to bind your passwords to your user account and store them on disk encrypted with a key only **accessible to processes running as the same logged on user.**

On macOS, Chrome is storing the credentials in “Login Data” in the Chrome users profile directory, but encrypted on disk with a key that is then stored in the user’s Keychain. Keychain uses [Access Control Lists](https://developer.apple.com/documentation/security/keychain_services/access_control_lists) that control which apps have access to keychain items in macOS, which makes it way harder to get the passwords.

## Legal Disclaimer
Usage of this code for attacking targets without prior mutual consent is illegal. It's the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program. Only use for educational purposes.

<img style="margin-top:100px" src="./resources/images/cactus.svg" width="128" />