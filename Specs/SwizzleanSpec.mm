#import <objc/runtime.h>
#import "Swizzlean.h"
#import "TestClass.h"
#import "RuntimeUtils.h"
#import "FakeRuntimeUtils.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface Swizzlean (Specs)

@property(nonatomic, readwrite) RuntimeUtils *runtimeUtils;

@property(nonatomic, readwrite) Class classToSwizzle;

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
    __block FakeRuntimeUtils *fakeRuntimeUtils;
    
    beforeEach(^{
        testClass = [TestClass class];
        swizzleanObj = [[Swizzlean alloc] initWithClassToSwizzle:testClass];
        
        fakeRuntimeUtils = [[FakeRuntimeUtils alloc] init];
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
            describe(@"when instance method doesn't exist", ^{
                __block SEL tacoMethodSEL;

                beforeEach(^{
                    swizzleanObj.isInstanceMethodSwizzled = NO;
                    swizzleanObj.runtimeUtils = nice_fake_for([RuntimeUtils class]);
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                    tacoMethodSEL = @selector(tacosAreYummy:);
#pragma clang diagnostic pop

                    swizzleanObj.runtimeUtils stub_method("getInstanceMethodWithClass:selector:").with(swizzleanObj.classToSwizzle).and_with(tacoMethodSEL).and_return((Method)NULL);
                });
                
                it(@"throws an exception", ^{
                    NSString *methodName = NSStringFromSelector(tacoMethodSEL);
                    NSString *reasonStr = [NSString stringWithFormat:@"Instance method doesn't exist: %@", methodName];
                    ^{
                        [swizzleanObj swizzleInstanceMethod:tacoMethodSEL withReplacementImplementation:replacementImpBlock];
                    } should raise_exception([NSException exceptionWithName:@"Swizzlean" reason:reasonStr userInfo:nil]);
                });
            });
            
            describe(@"when instance method hasn't been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isInstanceMethodSwizzled = NO;
                    [swizzleanObj swizzleInstanceMethod:instanceMethodSEL
                          withReplacementImplementation:replacementImpBlock];
                });
                
                it(@"stores the selector of original method", ^{
                    fakeRuntimeUtils.getInstanceMethodClass should equal(swizzleanObj.classToSwizzle);
                    fakeRuntimeUtils.getInstanceMethodSelector should equal(instanceMethodSEL);
                    swizzleanObj.currentInstanceMethodSwizzled should equal(instanceMethodSEL);
                });
                
                it(@"stores the original instance method to be swizzled", ^{
                    swizzleanObj.originalInstanceMethod should equal(originalInstanceMethod);
                });
                
                it(@"stores the replacement implementation block", ^{
                    fakeRuntimeUtils.getImplementationBlock should equal(replacementImpBlock);
                    swizzleanObj.replacementInstanceMethodImplementationBlock should equal(replacementImpBlock);
                });
                
                it(@"stores the replacement implementation from block", ^{
                    IMP fakeBlockImp = fakeRuntimeUtils.getImplementationBlockImp;
                    swizzleanObj.replacementInstanceMethodImplementation should equal(fakeBlockImp);
                });
                
                it(@"stores the original instance method implementation", ^{
                    IMP fakeBlockImp = fakeRuntimeUtils.getImplementationBlockImp;
                    
                    fakeRuntimeUtils.updateMethodImplementation should equal(fakeBlockImp);
                    swizzleanObj.originalInstanceMethodImplementation should equal(fakeRuntimeUtils.updateMethodSetImplementation);
                });
                
                it(@"sets isInstanceMethodSwizzled to YES", ^{
                    swizzleanObj.isInstanceMethodSwizzled should be_truthy;
                });
            });
            
            describe(@"when instance method has already been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isInstanceMethodSwizzled = YES;
                    spy_on(swizzleanObj.runtimeUtils);
                    [swizzleanObj swizzleInstanceMethod:instanceMethodSEL
                          withReplacementImplementation:replacementImpBlock];
                });
                
                afterEach(^{
                    stop_spying_on(swizzleanObj.runtimeUtils);
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
                    swizzleanObj.isInstanceMethodSwizzled = YES;
                    swizzleanObj.originalInstanceMethod = originalInstanceMethod;
                    swizzleanObj.originalInstanceMethodImplementation = originalImp;
                    swizzleanObj.replacementInstanceMethodImplementation = replacementImp;
                    swizzleanObj.currentInstanceMethodSwizzled = instanceMethodSEL;
                    
                    [swizzleanObj resetSwizzledInstanceMethod];
                });
                
                it(@"unswizzles the instance method (sets original implementation of instance method)", ^{
                    fakeRuntimeUtils.updateMethod should equal(originalInstanceMethod);
                    fakeRuntimeUtils.updateMethodImplementation should equal(originalImp);
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
                    
                    spy_on(swizzleanObj.runtimeUtils);
                    [swizzleanObj resetSwizzledInstanceMethod];
                });
                
                afterEach(^{
                    stop_spying_on(swizzleanObj.runtimeUtils);
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
            describe(@"when class method doesn't exist", ^{
                __block SEL burritoMethodSEL;

                beforeEach(^{
                    swizzleanObj.isClassMethodSwizzled = NO;
                    swizzleanObj.runtimeUtils = nice_fake_for([RuntimeUtils class]);
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                    burritoMethodSEL = @selector(returnStringInstanceMethod:);
#pragma clang diagnostic pop
                    
                    swizzleanObj.runtimeUtils stub_method("getClassMethodWithClass:selector:").with(swizzleanObj.classToSwizzle).and_with(burritoMethodSEL).and_return((Method)NULL);
                });
                
                it(@"throws an exception", ^{
                    NSString *methodName = NSStringFromSelector(burritoMethodSEL);
                    NSString *reasonStr = [NSString stringWithFormat:@"Class method doesn't exist: %@", methodName];
                    ^{
                        [swizzleanObj swizzleClassMethod:burritoMethodSEL withReplacementImplementation:replacementImpBlock];
                    } should raise_exception([NSException exceptionWithName:@"Swizzlean" reason:reasonStr userInfo:nil]);
                });
            });
            
            describe(@"when class method hasn't been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isClassMethodSwizzled = NO;
                    [swizzleanObj swizzleClassMethod:classMethodSEL withReplacementImplementation:replacementImpBlock];
                });
                
                it(@"stores the selector of class method", ^{
                    fakeRuntimeUtils.getClassMethodClass should equal(swizzleanObj.classToSwizzle);
                    fakeRuntimeUtils.getClassMethodSelector should equal(classMethodSEL);
                    swizzleanObj.currentClassMethodSwizzled should equal(classMethodSEL);
                });
                
                it(@"stores the original class method to be swizzled", ^{
                    swizzleanObj.originalClassMethod should equal(originalClassMethod);
                });
                
                it(@"stores the replacement implementation block", ^{
                    fakeRuntimeUtils.getImplementationBlock should equal(replacementImpBlock);
                    swizzleanObj.replacementClassMethodImplementationBlock should equal(replacementImpBlock);
                });
                
                it(@"stores the replacement implementation from block", ^{
                    IMP fakeBlockImp = fakeRuntimeUtils.getImplementationBlockImp;
                    swizzleanObj.replacementClassMethodImplementation should equal(fakeBlockImp);
                });
                
                it(@"stores the original class method implementation", ^{
                    IMP fakeBlockImp = fakeRuntimeUtils.getImplementationBlockImp;
                    
                    fakeRuntimeUtils.updateMethodImplementation should equal(fakeBlockImp);
                    swizzleanObj.originalClassMethodImplementation should equal(fakeRuntimeUtils.updateMethodSetImplementation);
                });
                
                it(@"sets isInstanceMethodSwizzled to YES", ^{
                    swizzleanObj.isClassMethodSwizzled should be_truthy;
                });
            });
            
            describe(@"when class method has already been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isClassMethodSwizzled = YES;
                    spy_on(swizzleanObj.runtimeUtils);
                    [swizzleanObj swizzleClassMethod:classMethodSEL withReplacementImplementation:replacementImpBlock];
                });
                
                afterEach(^{
                    stop_spying_on(swizzleanObj.runtimeUtils);
                });
                
                it(@"immediately returns", ^{
                    swizzleanObj.runtimeUtils should_not have_received(@selector(updateMethod:withImplemenation:));
                });
            });
        });
        
        context(@"#resetSwizzledClassMethod", ^{
            describe(@"when class method has already been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isClassMethodSwizzled = YES;
                    swizzleanObj.originalClassMethod = originalClassMethod;
                    swizzleanObj.originalClassMethodImplementation = originalImp;
                    swizzleanObj.replacementClassMethodImplementation = replacementImp;
                    swizzleanObj.currentClassMethodSwizzled = classMethodSEL;
                    [swizzleanObj resetSwizzledClassMethod];
                });
                
                it(@"unswizzles the class method (sets original implementation of class method)", ^{
                    fakeRuntimeUtils.updateMethod should equal(originalClassMethod);
                    fakeRuntimeUtils.updateMethodImplementation should equal(originalImp);
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
                    swizzleanObj.classToSwizzle = [NSObject class];
                    swizzleanObj.isClassMethodSwizzled = NO;
                });
                
                it(@"throws an exception", ^{
                    NSString *className = NSStringFromClass([NSObject class]);
                    NSString *reasonStr = [NSString stringWithFormat:@"Attempting to reset a swizzled class method when one doesn't exist for class %@", className];
                    ^{
                        [swizzleanObj resetSwizzledClassMethod];
                    } should raise_exception.with_name(@"Swizzlean").with_reason(reasonStr);
                });
            });
        });
    });
});

SPEC_END
