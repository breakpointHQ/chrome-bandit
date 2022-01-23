# Chrome Bandit

This is a proof of concept to show how your saved passwords on Google Chrome and other Chromium-based browsers can easily be stolen by any malicious program on macOS.

## Usage

```sh
chrome-bandit http://example.com
```

## Background

The way passwords are stored on Windows and macOS is different.

On Windows, Chrome uses the Data Protection API (DPAPI) to bind your passwords to your user account and store them on disk encrypted with a key only **accessible to processes running as the same logged on user.**

On macOS, Chrome is storing the credentials in “Login Data” in the Chrome users profile directory, but encrypted on disk with a key that is then stored in the user’s Keychain. Keychain uses [Access Control Lists](https://developer.apple.com/documentation/security/keychain_services/access_control_lists) that control which apps have access to keychain items in macOS, which makes it way harder to get the passwords.

## Legal Disclaimer
Usage of this code for attacking targets without prior mutual consent is illegal. It's the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program. Only use for educational purposes.
