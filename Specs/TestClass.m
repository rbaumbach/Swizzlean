#import "TestClass.h"


@implementation TestClass

#pragma mark - Instance Methods

- (NSString *)returnString:(NSString *)inputString
{
    return inputString;
}

#pragma mark - Class Methods

+ (NSString *)returnString:(NSString *)inputString
{
    return inputString;
}

@end
