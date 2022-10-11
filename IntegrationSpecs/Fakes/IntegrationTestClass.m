#import "IntegrationTestClass.h"

@implementation IntegrationTestClass

#pragma mark - Instance Methods

- (void)instanceMethod
{
    NSLog(@"Void instance method with no input.");
}

- (NSString *)instanceMethodReturnStringWithInput:(NSString *)inputA
                                         andInput:(NSString *)inputB
{
    return [NSString stringWithFormat:@"Instance Method: %@ + %@", inputA, inputB];
}

#pragma mark - Class Methods

+ (void)classMethod
{
    NSLog(@"Void class method with no input");
}

+ (NSString *)classMethodReturnStringWithInput:(NSString *)inputA
                                      andInput:(NSString *)inputB
{
    return [NSString stringWithFormat:@"Class Method: %@ + %@", inputA, inputB];
}

@end
