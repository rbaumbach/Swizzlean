#import "TestClass.h"

@implementation TestClass

#pragma mark - Instance Methods

- (NSString *)returnStringInstanceMethod:(NSString *)inputString
{
    return inputString;
}

#pragma mark - Class Methods

+ (NSString *)returnStringClassMethod:(NSString *)inputString
{
    return inputString;
}

@end
