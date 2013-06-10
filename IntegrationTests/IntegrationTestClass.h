#import <Foundation/Foundation.h>


@interface IntegrationTestClass : NSObject

- (void)instanceMethod;
- (NSString *)instanceMethodReturnStringWithInput:(NSString *)input;
- (NSString *)instanceMethodReturnStringWithInput:(NSString *)inputA
                                         andInput:(NSString *)inputB;

+ (void)classMethod;
+ (NSString *)classMethodReturnStringWithInput:(NSString *)input;
+ (NSString *)classMethodReturnStringWithInput:(NSString *)inputA
                                      andInput:(NSString *)inputB;

@end
