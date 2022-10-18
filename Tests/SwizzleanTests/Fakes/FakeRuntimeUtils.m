#import "FakeRuntimeUtils.h"
#import "TestClass.h"

@implementation FakeRuntimeUtils

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldReturnNULLForGetInstanceMethod = NO;
        self.updateMethodImplementationHasBeenCalled = NO;
    }
    return self;
}

- (Method)getInstanceMethodWithClass:(Class)klass selector:(SEL)selector
{
    self.getInstanceMethodClass = klass;
    self.getInstanceMethodSelector = selector;
    
    if (self.shouldReturnNULLForGetInstanceMethod) {
        return (Method)NULL;
    } else {
        return class_getInstanceMethod([TestClass class], @selector(returnStringInstanceMethod:));
    }
}

- (Method)getClassMethodWithClass:(Class)klass selector:(SEL)selector
{
    self.getClassMethodClass = klass;
    self.getClassMethodSelector = selector;
    
    if (self.shouldReturnNULLForGetClassMethod) {
        return (Method)NULL;
    } else {
        return class_getClassMethod([TestClass class], @selector(returnStringClassMethod:));
    }
}

- (IMP)getImplementationWithBlock:(id)blockImplemenation
{
    self.getImplementationBlock = [blockImplemenation copy];
    
    void (^emptyBlock)(void) = ^void() { };
    self.getImplementationBlockImp = imp_implementationWithBlock(emptyBlock);
    
    return self.getImplementationBlockImp;
}

- (IMP)updateMethod:(Method)method withImplemenation:(IMP)implementation
{
    self.updateMethodImplementationHasBeenCalled = YES;
    
    self.updateMethod = method;
    self.updateMethodImplementation = implementation;
    
    void (^emptyBlock)(void) = ^void() { };
    self.updateMethodSetImplementation = imp_implementationWithBlock(emptyBlock);
    
    return self.updateMethodSetImplementation;
}

@end
