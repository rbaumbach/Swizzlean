#import "FakeRuntimeUtils.h"
#import "TestClass.h"


@implementation FakeRuntimeUtils

- (Method)getInstanceMethodWithClass:(Class)klass selector:(SEL)selector
{
    self.getInstanceMethodClass = klass;
    self.getInstanceMethodSelector = selector;
    
    return class_getInstanceMethod([TestClass class], @selector(returnStringInstanceMethod:));
}

- (Method)getClassMethodWithClass:(Class)klass selector:(SEL)selector
{
    self.getClassMethodClass = klass;
    self.getClassMethodSelector = selector;
    
    return class_getClassMethod([TestClass class], @selector(returnStringClassMethod:));
}

- (IMP)getImplementationWithBlock:(id)blockImplemenation
{
    self.getImplementationBlock = [blockImplemenation copy];
    
    void (^emptyBlock)() = ^void() { };
    self.getImplementationBlockImp = imp_implementationWithBlock(emptyBlock);
    
    return self.getImplementationBlockImp;
}

- (IMP)updateMethod:(Method)method withImplemenation:(IMP)implementation
{
    self.updateMethod = method;
    self.updateMethodImplementation = implementation;
    
    void (^emptyBlock)() = ^void() { };
    self.updateMethodSetImplementation = imp_implementationWithBlock(emptyBlock);
    
    return self.updateMethodSetImplementation;
}

@end
