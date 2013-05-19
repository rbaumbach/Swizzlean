#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface Swizzlean : NSObject

@property(nonatomic, readonly) Class classToSwizzle;


- (id)initWithClassToSwizzle:(Class)swizzleClass;

- (void)swizzleClassMethod:(SEL)originalMethod withReplacementImplementation:(id)replacementImplementation;

@end
