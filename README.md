# Strap
Hatstrap is a script to bootstrap a minimal OS X development system, forked from [Strap](https://github.com/mikemcquaid/strap)
## Features
- Sets a bunch of Preferences (details in `bin/prefs.sh`)
- Adds a `Found this computer?` message to the login screen (for machine recovery)
- Installs the Xcode Command Line Tools (for compilers and Unix tools)
- Agree to the Xcode license (for using compilers without prompts)
- Installs [Homebrew](http://brew.sh) (for installing command-line software)
- Installs [Homebrew Versions](https://github.com/Homebrew/homebrew-versions) (for installing older versions of command-line software)
- Installs [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle) (for `bundler`-like `Brewfile` support)
- Installs [Homebrew Services](https://github.com/Homebrew/homebrew-services) (for managing Homebrew-installed services)
- Installs [Homebrew Cask](https://github.com/caskroom/homebrew-cask) (for installing graphical software)
- Installs the latest OS X software updates (for better security)
- Installs a bunch of apps for Software Development
- Adds basic Apache, PHP, MySQL, PHPMyAdmin support w/ vHosts

## License
Hatstrap is forked from Strap and trimmed to fit.

Strap is licensed under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
The full license text is available in [LICENSE.txt](https://github.com/mikemcquaid/strap/blob/master/LICENSE.txt).
