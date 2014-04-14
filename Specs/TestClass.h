#import <Foundation/Foundation.h>


@interface TestClass : NSObject

- (NSString *)returnStringInstanceMethod:(NSString *)inputString;

+ (NSString *)returnStringClassMethod:(NSString *)inputString;

@end
