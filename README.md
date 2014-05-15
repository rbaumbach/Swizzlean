# Swizzlean  [![Build Status](https://travis-ci.org/rbaumbach/Swizzlean.png)](https://travis-ci.org/rbaumbach/Swizzlean) [![Cocoapod Version](https://cocoapod-badges.herokuapp.com/v/Swizzlean/badge.png)](http://cocoapods.org/?q=Swizzlean) [![Cocoapod Platform](https://cocoapod-badges.herokuapp.com/p/Swizzlean/badge.png)](http://cocoapods.org/?q=Swizzlean) [![License](http://b.repl.ca/v1/License-MIT-blue.png)](https://github.com/rbaumbach/Swizzlean/blob/master/MIT.LICENSE)

A quick and "lean" way to swizzle methods for your Objective-C development needs.

## Adding Swizzlean to your project

### Cocoapods

[CocoaPods](http://cocoapods.org) is the recommended way to add Swizzlean to your project.

1.  Add Swizzlean to your Podfile `pod 'Swizzlean'`.
2.  Install the pod(s) by running `pod install`.
3.  Include Swizzlean to your files with `#import <Swizzlean/Swizzlean.h>`.

### Clone from Github

1.  Clone repository from github and copy files directly, or add it as a git submodule.
2.  Add Swizzlean and RuntimeUtils (.h and .m) files to your project.

## How To

* Create an instance of swizzlean passing in the class of the methods you want to swizzle.
* Call swizzleInstanceMethod:withReplacementImplementation: for an instance method passing 
  in the selector of the method to be swizzled with the replacement implementation.  When
  passing in the replacement implementation block, the first parameter is always id _self
  (pointer to the 'Class' being swizzled), and the followed by any other parameters for the
  method being swizzled.
* Call swizzleClassMethod:withReplacementImplementation: for a class method passing in
  the selector of the method to be swizzled with the replacement implementation.
* You can check the current instance/class method that is swizzled by using the 
  currentInstanceMethodSwizzled and currentClassMethodSwizzled methods.
* The status of the swizzled methods can be seen by calling isInstanceMethodSwizzled and
  isClassMethodSwizzled.
* Use reset methods to unswizzle the instance/class methods that are currently being
  swizzled.

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

To use the included Rakefile to run Cedar specs, run the setup.sh script to bundle required gems and cocoapods:

```bash
$ ./setup.sh
```

Then run rake to run cedar specs on the command line:

```bash
$ bundle exec rake
```

Additional rake tasks can be seen using rake -T:

```bash
$ rake -T
rake build_swizzlean    # Build Swizzlean
rake clean[target]      # Clean target
rake clean_all_targets  # Clean all target
rake integration_specs  # Run Integration Specs
rake run_all_specs      # Run all Specs
rake specs              # Run Specs
```

## Suggestions, requests, feedback and acknowledgements

Thanks for checking out Swizzlean for your swizzling.  Any feedback can be 
can be sent to: rbaumbach.github@gmail.com.

This software is licensed under the MIT License.

Thanks to the following contributors for keeping Swizzlean Swizzletastic:
Erik Stromlund & Aaron Koop

