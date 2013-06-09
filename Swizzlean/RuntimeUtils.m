#import <objc/runtime.h>
#import "RuntimeUtils.h"


@implementation RuntimeUtils

- (Class)getMetaClassFromClassString:(NSString *)className
{
    return object_getClass(NSClassFromString(className));
}

- (Method)getClassMethodWithClass:(Class)klass selector:(SEL)selector
{
    return class_getClassMethod(klass, selector);
}

- (Method)getInstanceMethodWithClass:(Class)klass selector:(SEL)selector
{
    return class_getInstanceMethod(klass, selector);
}

- (IMP)getImplementationWithBlock:(id)blockImplemenation
{
    return imp_implementationWithBlock(blockImplemenation);
}

- (IMP)setMethod:(Method)method withImplemenation:(IMP)implementation
{
    return method_setImplementation(method, implementation);
}

@end
