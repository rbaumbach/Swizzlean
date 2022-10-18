#import <Foundation/Foundation.h>

@interface IntegrationTestClass : NSObject

- (void)instanceMethod;
- (NSString *)instanceMethodReturnStringWithInput:(NSString *)inputA
                                         andInput:(NSString *)inputB;

+ (void)classMethod;
+ (NSString *)classMethodReturnStringWithInput:(NSString *)inputA
                                      andInput:(NSString *)inputB;

@end
