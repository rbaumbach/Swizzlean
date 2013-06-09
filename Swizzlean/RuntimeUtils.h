#import <objc/runtime.h>


@interface RuntimeUtils : NSObject

- (Class)getMetaClassFromClassString:(NSString *)klass;

- (Method)getInstanceMethodWithClass:(Class)klass selector:(SEL)selector;
- (Method)getClassMethodWithClass:(Class)klass selector:(SEL)selector;

- (IMP)getImplementationWithBlock:(id)blockImplemenation;
- (IMP)updateMethod:(Method)method withImplemenation:(IMP)implementation;

@end
