#import <objc/runtime.h>


@interface RuntimeUtils : NSObject

- (Class)getMetaClassFromClassString:(NSString *)klass;

- (Method)getClassMethodWithClass:(Class)klass selector:(SEL)selector;
- (Method)getInstanceMethodWithClass:(Class)klass selector:(SEL)selector;

- (IMP)getImplementationWithBlock:(id)blockImplemenation;
- (IMP)setMethod:(Method)method withImplemenation:(IMP)implementation;

@end
