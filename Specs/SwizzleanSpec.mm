#import <objc/runtime.h>
#import "Swizzlean.h"
#import "TestClass.h"
#import "RuntimeUtils.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface Swizzlean (Specs)

@property(nonatomic, readwrite) RuntimeUtils *runtimeUtils;

@property(nonatomic, readwrite) Method originalInstanceMethod;
@property(nonatomic, readwrite) Method originalClassMethod;
@property(nonatomic, readwrite) IMP originalInstanceMethodImplementation;
@property(nonatomic, readwrite) IMP originalClassMethodImplementation;

@property(copy, nonatomic, readwrite) id replacementInstanceMethodImplementationBlock;
@property(copy, nonatomic, readwrite) id replacementClassMethodImplementationBlock;
@property(nonatomic, readwrite) IMP replacementInstanceMethodImplementation;
@property(nonatomic, readwrite) IMP replacementClassMethodImplementation;

@property(nonatomic, readwrite) SEL currentInstanceMethodSwizzled;
@property(nonatomic, readwrite) SEL currentClassMethodSwizzled;

@property(nonatomic, readwrite) BOOL isInstanceMethodSwizzled;
@property(nonatomic, readwrite) BOOL isClassMethodSwizzled;

@end


SPEC_BEGIN(SwizzleanSpec)

describe(@"Swizzlean", ^{
    __block Swizzlean *swizzleanObj;
    __block Class testClass;
    __block RuntimeUtils *fakeRuntimeUtils;
    
    beforeEach(^{
        testClass = [TestClass class];
        swizzleanObj = [[[Swizzlean alloc] initWithClassToSwizzle:testClass] autorelease];
        
        fakeRuntimeUtils = nice_fake_for([RuntimeUtils class]);
        swizzleanObj.runtimeUtils = fakeRuntimeUtils;
    });
    
    it(@"has an instance of RuntimeUtils", ^{
        swizzleanObj.runtimeUtils should_not be_nil;
    });

    it(@"stores the class", ^{
        swizzleanObj.classToSwizzle should equal(testClass);
    });
    
    it(@"sets the isClassMethodSwizzled to NO", ^{
        swizzleanObj.isClassMethodSwizzled should_not be_truthy;
    });
    
    it(@"sets the isInstanceMethodSwizzled to NO", ^{
        swizzleanObj.isInstanceMethodSwizzled should_not be_truthy;
    });
    
    it(@"has a currentInstanceMethodSwizzled: that is nil", ^{
        swizzleanObj.currentInstanceMethodSwizzled should be_nil;
    });
    
    it(@"has a currentClassMethodSwizzled: that is nil", ^{
        swizzleanObj.currentClassMethodSwizzled should be_nil;
    });
    
    describe(@"Instance method swizzling", ^{
        __block SEL instanceMethodSEL;
        __block Method originalInstanceMethod;
        __block id replacementImpBlock;
        __block IMP replacementImp;
        __block IMP originalImp;
        
        beforeEach(^{
            instanceMethodSEL = @selector(returnStringInstanceMethod:);
            originalInstanceMethod = class_getInstanceMethod(testClass, instanceMethodSEL);
            replacementImpBlock = ^(id _self, NSString *input) { };
            replacementImp = imp_implementationWithBlock(replacementImpBlock);
            originalImp = [TestClass methodForSelector:instanceMethodSEL];
        });
        
        context(@"#swizzleInstanceMethod:withReplacementImplementation:", ^{
            __block SEL classMethodSEL;
            
            describe(@"when instance method doesn't exist", ^{
                beforeEach(^{
                    classMethodSEL = @selector(returnStringClassMethod:);
                    fakeRuntimeUtils stub_method("getInstanceMethodWithClass:selector:").with(swizzleanObj.classToSwizzle).and_with(classMethodSEL).and_return((Method)NULL);
                    swizzleanObj.isInstanceMethodSwizzled = NO;
                });
                
                it(@"throws an exception", ^{
                    NSString *methodName = NSStringFromSelector(classMethodSEL);
                    NSString *reasonStr = [NSString stringWithFormat:@"Instance method doesn't exist: %@", methodName];
                    ^{
                        [swizzleanObj swizzleInstanceMethod:classMethodSEL withReplacementImplementation:replacementImpBlock];
                    } should raise_exception([NSException exceptionWithName:@"Swizzlean" reason:reasonStr userInfo:nil]);
                });
            });
            
            describe(@"when instance method hasn't been swizzled", ^{
                beforeEach(^{
                    fakeRuntimeUtils stub_method("getInstanceMethodWithClass:selector:").with(swizzleanObj.classToSwizzle).and_with(instanceMethodSEL).and_return(originalInstanceMethod);
                    fakeRuntimeUtils stub_method("getImplementationWithBlock:").with(replacementImpBlock).and_return(replacementImp);
                    fakeRuntimeUtils stub_method("updateMethod:withImplemenation:").with(originalInstanceMethod).and_with(replacementImp).and_return(originalImp);
                    swizzleanObj.isInstanceMethodSwizzled = NO;
                    [swizzleanObj swizzleInstanceMethod:instanceMethodSEL withReplacementImplementation:replacementImpBlock];
                });
                
                it(@"stores the selector of original method", ^{
                    swizzleanObj.currentInstanceMethodSwizzled should equal(instanceMethodSEL);
                });
                
                it(@"stores the original instance method to be swizzled", ^{
                    swizzleanObj.originalInstanceMethod should equal(originalInstanceMethod);
                });
                
                it(@"stores the replacement implementation block", ^{
                    swizzleanObj.replacementInstanceMethodImplementationBlock should equal(replacementImpBlock);
                });
                
                it(@"stores the replacement implementation from block", ^{
                    swizzleanObj.replacementInstanceMethodImplementation should equal(replacementImp);
                });
                
                it(@"stores the original instance method implementation", ^{
                    swizzleanObj.originalInstanceMethodImplementation should equal(originalImp);
                });
                
                it(@"sets isInstanceMethodSwizzled to YES", ^{
                    swizzleanObj.isInstanceMethodSwizzled should be_truthy;
                });
            });
            
            describe(@"when instance method has already been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isInstanceMethodSwizzled = YES;
                    [swizzleanObj swizzleInstanceMethod:instanceMethodSEL withReplacementImplementation:replacementImpBlock];
                });
                
                it(@"immediately returns", ^{
                    swizzleanObj.runtimeUtils should_not have_received(@selector(getInstanceMethodWithClass:selector:));
                    swizzleanObj.runtimeUtils should_not have_received(@selector(getImplementationWithBlock:));
                    swizzleanObj.runtimeUtils should_not have_received(@selector(updateMethod:withImplemenation:));
                });
            });
        });
        
        context(@"#resetSwizzledInstanceMethod", ^{            
            describe(@"when instance method has been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.originalInstanceMethod = originalInstanceMethod;
                    swizzleanObj.originalInstanceMethodImplementation = originalImp;
                    swizzleanObj.replacementInstanceMethodImplementation = replacementImp;
                    swizzleanObj.currentInstanceMethodSwizzled = instanceMethodSEL;
                    swizzleanObj.isInstanceMethodSwizzled = YES;
                    [swizzleanObj resetSwizzledInstanceMethod];
                });
                
                it(@"unswizzles the instance method (sets original implementation of instance method)", ^{
                    swizzleanObj.runtimeUtils should have_received(@selector(updateMethod:withImplemenation:)).with(originalInstanceMethod).and_with(originalImp);
                });
                
                it(@"resets instance method", ^{
                    swizzleanObj.originalInstanceMethod should be_nil;
                    swizzleanObj.originalInstanceMethodImplementation should be_nil;
                });
                
                it(@"resets replacement instance method implementation", ^{
                    swizzleanObj.replacementInstanceMethodImplementation should be_nil;
                });
                
                it(@"resets the SEL of the original instance method swizzled", ^{
                    swizzleanObj.currentInstanceMethodSwizzled should be_nil;
                });
                
                it(@"sets the isInstanceMethodSwizzled to NO", ^{
                    swizzleanObj.isInstanceMethodSwizzled should_not be_truthy;
                });
            });
            
            describe(@"when instance method has not been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isInstanceMethodSwizzled = NO;
                    [swizzleanObj resetSwizzledInstanceMethod];
                });
                
                it(@"immediately returns", ^{
                    swizzleanObj.runtimeUtils should_not have_received(@selector(updateMethod:withImplemenation:));
                });
            });
        });
    });
    
    describe(@"Class method swizzling", ^{
        __block SEL classMethodSEL;
        __block Method originalClassMethod;
        __block id replacementImpBlock;
        __block IMP replacementImp;
        __block IMP originalImp;
        
        beforeEach(^{
            classMethodSEL = @selector(returnStringClassMethod:);
            originalClassMethod = class_getClassMethod(swizzleanObj.classToSwizzle, classMethodSEL);
            replacementImpBlock = ^(id _self, NSString *input) { };
            replacementImp = imp_implementationWithBlock(replacementImpBlock);
            originalImp = [TestClass methodForSelector:classMethodSEL];
        });
        
        context(@"#swizzleClassMethod:withReplacementImplementation:", ^{
            __block SEL instanceMethodSEL;
            
            describe(@"when class method doesn't exist", ^{
                beforeEach(^{
                    instanceMethodSEL = @selector(returnStringInstanceMethod:);
                    fakeRuntimeUtils stub_method("getClassMethodWithClass:selector:").with(swizzleanObj.classToSwizzle).and_with(instanceMethodSEL).and_return((Method)NULL);
                    swizzleanObj.isClassMethodSwizzled = NO;
                });
                
                it(@"throws an exception", ^{
                    NSString *methodName = NSStringFromSelector(instanceMethodSEL);
                    NSString *reasonStr = [NSString stringWithFormat:@"Class method doesn't exist: %@", methodName];
                    ^{
                        [swizzleanObj swizzleClassMethod:instanceMethodSEL withReplacementImplementation:replacementImpBlock];
                    } should raise_exception([NSException exceptionWithName:@"Swizzlean" reason:reasonStr userInfo:nil]);
                });
            });
            
            describe(@"when class method hasn't been swizzled", ^{
                beforeEach(^{
                    fakeRuntimeUtils stub_method("getClassMethodWithClass:selector:").with(swizzleanObj.classToSwizzle).and_with(classMethodSEL).and_return(originalClassMethod);
                    fakeRuntimeUtils stub_method("getImplementationWithBlock:").with(replacementImpBlock).and_return(replacementImp);
                    fakeRuntimeUtils stub_method("updateMethod:withImplemenation:").with(originalClassMethod).and_with(replacementImp).and_return(originalImp);
                    swizzleanObj.isClassMethodSwizzled = NO;
                    [swizzleanObj swizzleClassMethod:classMethodSEL withReplacementImplementation:replacementImpBlock];
                });
                
                it(@"stores the selector of class method", ^{
                    swizzleanObj.currentClassMethodSwizzled should equal(classMethodSEL);
                });
                
                it(@"stores the original class method to be swizzled", ^{
                    swizzleanObj.originalClassMethod should equal(originalClassMethod);
                });
                
                it(@"stores the replacement implementation block", ^{
                    swizzleanObj.replacementClassMethodImplementationBlock should equal(replacementImpBlock);
                });
                
                it(@"stores the replacement implementation from block", ^{
                    swizzleanObj.replacementClassMethodImplementation should equal(replacementImp);
                });
                
                it(@"stores the original class method implementation", ^{
                    swizzleanObj.originalClassMethodImplementation should equal(originalImp);
                });
                
                it(@"sets isInstanceMethodSwizzled to YES", ^{
                    swizzleanObj.isClassMethodSwizzled should be_truthy;
                });
            });
            
            describe(@"when class method has already been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isClassMethodSwizzled = YES;
                    [swizzleanObj swizzleClassMethod:classMethodSEL withReplacementImplementation:replacementImpBlock];
                });
                
                it(@"immediately returns", ^{
                    swizzleanObj.runtimeUtils should_not have_received(@selector(updateMethod:withImplemenation:));
                });
            });
        });
        
        context(@"#resetSwizzledClassMethod", ^{
            describe(@"when class method has already been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.originalClassMethod = originalClassMethod;
                    swizzleanObj.originalClassMethodImplementation = originalImp;
                    swizzleanObj.replacementClassMethodImplementation = replacementImp;
                    swizzleanObj.currentClassMethodSwizzled = classMethodSEL;
                    swizzleanObj.isClassMethodSwizzled = YES;
                    [swizzleanObj resetSwizzledClassMethod];
                });
                
                it(@"unswizzles the class method (sets original implementation of class method)", ^{
                    swizzleanObj.runtimeUtils should have_received(@selector(updateMethod:withImplemenation:)).with(originalClassMethod).and_with(originalImp);
                });
                
                it(@"resets class method", ^{
                    swizzleanObj.originalClassMethod should be_nil;
                    swizzleanObj.originalClassMethodImplementation should be_nil;
                });
                
                it(@"resets replacement class method implementation", ^{
                    swizzleanObj.replacementClassMethodImplementation should be_nil;
                });
                
                it(@"resets the SEL of the original class method swizzled", ^{
                    swizzleanObj.currentClassMethodSwizzled should be_nil;
                });
                
                it(@"sets the isClassMethodSwizzled to NO", ^{
                    swizzleanObj.isClassMethodSwizzled should_not be_truthy;
                });
            });
            
            describe(@"when class method has not been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isClassMethodSwizzled = NO;
                    [swizzleanObj resetSwizzledClassMethod];
                });
                
                it(@"immediately returns", ^{
                    swizzleanObj.runtimeUtils should_not have_received(@selector(updateMethod:withImplemenation:));
                });
            });
        });
    });
});

SPEC_END
