# Bright

Bright is meant as a little demonstration application showcasing several aspect of iOS development.

## What
- [x] SwiftUI
- [x] MVVM & Coordinator
- [x] Big usage of protocols oriented dev
- [x] Uses latest Apple's [Combine](https://developer.apple.com/documentation/combine)
- [x] Use dependency injection
- [x] Embarks Cache / Image lazy loading / Network / Some animation
- [x] Pure Swift
- [x] iOS 13 compitible

## ToDo
- [x] Implement Linters (swiftlint/ swiftformat)
- [x] Implement Testing 
- [x] Implement new feature 
- [x] Use dependency injection
- [x] Documentation


### About the project

I wanted to try a achieve the implementation of this project using only SwiftUI.
This is quite a challenge about of the iOS backward compatibility going back to iOS13 and SwitUI 1.0.
This version of SwiftUI is limited compared to the new versions. Therefor I had to try and find or build workarounds for some of the difficulties I encountered.

The project in build around the `MVVM & Coordinator` pattern. It is a well known and shoudl be easy to comprehend.
To keep a `Clean and SOLID architecture` all the networking is done in repositories that are injected through `dependency injection` to the viewModel.

The communication between the element of the project is mainly done throught `Combine Publishers`. The data flow come from single soruces of trouth that are the repositories.

### Tooling

The Cache system is based on a very simple Generic NSCache implementation.

The Network implementation is based on a small networking library I created based around the new combine publisher integrated into URLSession Data tasks.
I enables us to easily create network services using the power of swift generics. 
[Jolt](https://github.com/lukacs-m/Jolt)

The Depency injection tool is a simplyfied version of Resolver. 
[Resolver](https://github.com/hmlongco/Resolver)
