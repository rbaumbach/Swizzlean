#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface Swizzlean : NSObject

@property(nonatomic, readonly) Class classToSwizzle;
@property(nonatomic, readonly) BOOL isClassMethodSwizzled;
@property(nonatomic, readonly) BOOL isInstanceMethodSwizzled;

- (id)initWithClassToSwizzle:(Class)swizzleClass;

- (void)swizzleClassMethod:(SEL)originalMethod withReplacementImplementation:(id)replacementImplementation;
- (void)swizzleInstanceMethod:(SEL)originalMethod withReplacementImplementation:(id)replacementImplementation;

- (void)unswizzleClassMethod;

@end
