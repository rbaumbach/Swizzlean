# Swizzlean  [![Build Status](https://travis-ci.org/rbaumbach/Swizzlean.png)](https://travis-ci.org/rbaumbach/Swizzlean)

A quick and "lean" way to swizzle methods for your Objective-C development needs.

## Adding Swizzlean to your project

### Cocoapods

[CocoaPods](http://cocoapods.org) is the recommended way to add Swizzlean to your project.

1.  Add Swizzlean to your Podfile `pod 'Swizzlean', '~> 0.1.0'`.
2.  Install the pod(s) by running `pod install`.
3.  Include Swizzlean to your files with `#import "Swizzlean.h"`.

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

## Suggestions, requests and feedback

Thanks for checking out Swizzlean for your swizzling.  Any feedback can be 
can be sent to: rbaumbach.github@gmail.com.

This software is licensed under the MIT License.
