fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### bump_version

```sh
[bundle exec] fastlane bump_version
```

Bump version from merge commit and push tag

----


## iOS

### ios generate_project

```sh
[bundle exec] fastlane ios generate_project
```

Generate the Xcode project using XcodeGen

### ios build_debug

```sh
[bundle exec] fastlane ios build_debug
```

Verify iOS/iPadOS debug build

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Verify iOS/iPadOS release build

### ios sync_profiles

```sh
[bundle exec] fastlane ios sync_profiles
```

Generate/sync development and App Store provisioning profiles for iOS/iPadOS

### ios distribute

```sh
[bundle exec] fastlane ios distribute
```

Build and upload iOS/iPadOS release to App Store Connect

----


## Mac

### mac generate_project

```sh
[bundle exec] fastlane mac generate_project
```

Generate the Xcode project using XcodeGen

### mac build_debug

```sh
[bundle exec] fastlane mac build_debug
```

Verify macOS debug build

### mac build_release

```sh
[bundle exec] fastlane mac build_release
```

Verify macOS release build

### mac sync_profiles

```sh
[bundle exec] fastlane mac sync_profiles
```

Generate/sync development and App Store provisioning profiles for macOS (Mac Catalyst)

### mac distribute

```sh
[bundle exec] fastlane mac distribute
```

Build and upload macOS release to App Store Connect

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
