# Swizzlean [![Bitrise](https://app.bitrise.io/app/805069fee450821d/status.svg?token=DSHtzhY3hCKTrW_H41JyIA&branch=master)](https://app.bitrise.io/app/805069fee450821d) [![Cocoapod Version](https://img.shields.io/cocoapods/v/Swizzlean.svg)](http://cocoapods.org/?q=Swizzlean) [![Cocoapod Platform](http://img.shields.io/badge/platform-iOS-blue.svg)](http://cocoapods.org/?q=Swizzlean) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![License](https://img.shields.io/dub/l/vibe-d.svg)](https://github.com/rbaumbach/Swizzlean/blob/master/MIT-LICENSE.txt)

A quick and "lean" way to swizzle methods for your Objective-C development needs.

## Adding Swizzlean to your project

### Cocoapods

[CocoaPods](http://cocoapods.org) is the recommended way to add `Swizzlean` to your project.

1.  Add Swizzlean to your Podfile `pod 'Swizzlean'`.
2.  Install the pod(s) by running `pod install`.
3.  Add Swizzlean to your files with `#import <Swizzlean/Swizzlean.h>`.

### Swift Package Manager (SPM)

[Swift Package Manager](https://swift.org/package-manager/) can be used to add `Swizzlean` the to your project:

1.  Add `.package(url: "https://github.com/rbaumbach/Swizzlean", from: "1.1.0")`
2.  [Follow intructions to add](https://swift.org/getting-started/#using-the-package-manager) the `Swizzlean` package to your project.

### Carthage

You can also use [Carthage](https://github.com/Carthage/Carthage) to manually add the `Swizzlean` framework to your project.

1. Add `github "rbaumbach/Swizzlean"` to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).
2. [Follow instructions to manually add](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) Swizzlean dynamic framework to your project.

### Clone from Github

1.  Clone repository from github and copy files directly, or add it as a git submodule.
2.  Add Swizzlean and RuntimeUtils (.h and .m) files to your project.

## How To

* Create an instance of **Swizzlean** passing in the class of the methods you want to swizzle.
* Call `swizzleInstanceMethod:withReplacementImplementation:` for an instance method passing
  in the selector of the method to be swizzled with the replacement implementation.  When
  passing in the replacement implementation block, the first parameter is always `id _self`
  (pointer to the 'Class' being swizzled), and the followed by any other parameters for the
  method being swizzled.
* Call `swizzleClassMethod:withReplacementImplementation:` for a class method passing in
  the selector of the method to be swizzled with the replacement implementation.
* You can check the current instance/class method that is swizzled by using the
  `currentInstanceMethodSwizzled` and `currentClassMethodSwizzled` methods.
* The status of the swizzled methods can be seen by calling `isInstanceMethodSwizzled` and
  `isClassMethodSwizzled`.
* Use reset methods to unswizzle the instance/class methods that are currently being
  swizzled.
* Methods are automatically reset when the Swizzlean object is deallocated.  If you would like to
  keep the methods swizzled after `dealloc` is called, set the property `resetWhenDeallocated = NO`.

### Example Usage

```objective-c
Swizzlean *swizzle = [[Swizzlean alloc] initWithClassToSwizzle:[NSString class]];
[swizzle swizzleInstanceMethod:@selector(intValue) withReplacementImplementation:^(id _self) {
    return 42;
}];
NSString *number7 = @"7";
NSLog(@"The int value for number7 is: %d", [number7 intValue]);
// returns - The int value for number7 is: 42
[swizzle resetSwizzledInstanceMethod];
NSLog(@"The int value for number7 is: %d", [number7 intValue]);
// returns - The int value for number7 is: 7
```

## Testing

* Prerequisites: [ruby](https://github.com/sstephenson/rbenv), [ruby gems](https://rubygems.org/pages/download), [bundler](http://bundler.io)

This project has been setup to use [fastlane](https://fastlane.tools) to run the specs.

First, run the `setup.sh` script to bundle required gems and `Cocoapods` when in the project directory:

```bash
$ ./setup.sh
```

And then use `fastlane` to run all the specs on the command line:

```bash
$ bundle exec fastlane specs
```

## Version History

Version history can be found [on releases page](https://github.com/rbaumbach/Swizzlean/releases).

## Suggestions, requests, feedback and acknowledgements

Thanks for checking out `Swizzlean` for your swizzling needs.  Any feedback can be
can be sent to: <github@ryan.codes>.

Thanks to the following contributors for keeping `Swizzlean` Swizzletastic:
[Erik Stromlund](https://github.com/estromlund) & [Aaron Koop](https://github.com/aaronkoop)
