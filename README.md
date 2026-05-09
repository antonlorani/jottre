<p style="text-align: center; max-width: 500px; height: auto;">
<p align="center" >
  <img src="Resources/Assets.xcassets/AppIcon.appiconset/icon_1024x1024.png" style="border-radius: 50px; overflow: hidden;" width=300 height=auto>
</p>

# Jottre

Simple and minimalistic handwriting app across Apple platforms.

**Available on the [App Store](https://apps.apple.com/us/app/jottre/id1550272319)**

![Jottre on iPad App Preview](jottre_ipad_app_preview.jpg)

## Contributing

Contributions are welcome. Before opening an issue or pull request, please review the following documents:

- [Contributing guidelines](CONTRIBUTING.md)
- [Code of conduct](CODE_OF_CONDUCT.md)
- [Security policy](SECURITY_POLICY.md)

## Development

### Installation

Configure the Ruby toolchain with [rbenv](https://github.com/rbenv/rbenv):

```sh
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
rbenv install $(cat .ruby-version)
rbenv local $(cat .ruby-version)
```

Install Bundler and the project's Ruby dependencies:

```sh
gem install bundler
bundle install
```

Install Xcode at the pinned version using [xcodes](https://github.com/XcodesOrg/xcodes):

```sh
brew install xcodesorg/made/xcodes
brew install aria2
xcodes install $(cat .xcode-version) --experimental-unxip
xcodes select $(cat .xcode-version)
```

Generate the Xcode project:

```sh
bundle exec fastlane generate_project
```

### Validation

Verify the setup by running the test suite:

```sh
bundle exec fastlane test
```

## License

Copyright (C) 2021-2026 Anton Lorani

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
