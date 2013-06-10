#import "IntegrationTestClass.h"


@implementation IntegrationTestClass

#pragma mark - Instance Methods

- (void)instanceMethod
{
    NSLog(@"Void instance method with no input.");
}

- (NSString *)instanceMethodReturnStringWithInput:(NSString *)input
{
    return input;
}

- (NSString *)instanceMethodReturnStringWithInput:(NSString *)inputA
                                         andInput:(NSString *)inputB
{
    return [NSString stringWithFormat:@"%@ + %@", inputA, inputB];
}

#pragma mark - Class Methods

+ (void)classMethod
{
    NSLog(@"Void class method with no input");
}

+ (NSString *)classMethodReturnStringWithInput:(NSString *)input
{
    return input;
}

+ (NSString *)classMethodReturnStringWithInput:(NSString *)inputA
                                      andInput:(NSString *)inputB
{
    return [NSString stringWithFormat:@"%@ + %@", inputA, inputB];
}

@end
