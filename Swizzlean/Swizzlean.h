#import <Foundation/Foundation.h>


@interface Swizzlean : NSObject

@property(nonatomic, readonly) Class classToSwizzle;
@property(nonatomic, readonly) BOOL isInstanceMethodSwizzled;
@property(nonatomic, readonly) BOOL isClassMethodSwizzled;
@property(nonatomic, readonly) SEL currentInstanceMethodSwizzled;
@property(nonatomic, readonly) SEL currentClassMethodSwizzled;

- (id)initWithClassToSwizzle:(Class)swizzleClass;

- (void)swizzleInstanceMethod:(SEL)originalMethod withReplacementImplementation:(id)replacementImplementation;
- (void)swizzleClassMethod:(SEL)originalMethod withReplacementImplementation:(id)replacementImplementation;

- (void)resetSwizzledInstanceMethod;
- (void)resetSwizzledClassMethod;

@end
