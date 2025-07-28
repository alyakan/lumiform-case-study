# lumiform-case-study

[![Swift](https://github.com/alyakan/lumiform-case-study/actions/workflows/CI.yml/badge.svg)](https://github.com/alyakan/lumiform-case-study/actions/workflows/CI.yml)

## Lumiform

- The `Lumiform` target was created as a macOS target for faster TDD. 
- While developing a macOS target, you can choose your own Mac as the build target, hence there's no need to build and launch a simulator. 
- The target is made to support `iphoneos` and `iphonesimulator` platforms and so they can be linked to iOS projects with no problem.

## LumiformApp

- The `LumiformApp` target is an iOS SwiftUI target created in a separate project.
- A workspace with the same name was created to house both the `Lumiform` and `LumiformApp` projects.
- The `Lumiform` target is linked against this target so the app can import and use its public classes.