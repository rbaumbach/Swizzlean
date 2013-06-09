#import <objc/runtime.h>
#import "Swizzlean.h"
#import "TestClass.h"
#import "RuntimeUtils.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface Swizzlean (Specs)

@property(nonatomic, readwrite) RuntimeUtils *runtimeUtils;

@property(nonatomic, readwrite) Method originalClassMethod;
@property(nonatomic, readwrite) Method originalInstanceMethod;
@property(nonatomic, readwrite) IMP originalClassMethodImplementation;
@property(nonatomic, readwrite) IMP originalInstanceMethodImplementation;

@property(copy, nonatomic, readwrite) id replacementClassMethodImplementationBlock;
@property(copy, nonatomic, readwrite) id replacementInstanceMethodImplementationBlock;
@property(nonatomic, readwrite) IMP replacementInstanceMethodImplementation;
@property(nonatomic, readwrite) IMP replacementClassMethodImplementation;

@property(nonatomic, readwrite) BOOL isClassMethodSwizzled;
@property(nonatomic, readwrite) BOOL isInstanceMethodSwizzled;

@end


SPEC_BEGIN(SwizzleanSpec)

describe(@"Swizzlean", ^{
    __block Swizzlean *swizzleanObj;
    __block Class testClass;
    __block RuntimeUtils *fakeRuntimeUtils;
    
    beforeEach(^{
        testClass = [TestClass class];
        swizzleanObj = [[Swizzlean alloc] initWithClassToSwizzle:testClass];
        
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
            beforeEach(^{
                fakeRuntimeUtils stub_method("getInstanceMethodWithClass:selector:").with(swizzleanObj.classToSwizzle).and_with(instanceMethodSEL).and_return(originalInstanceMethod);
                fakeRuntimeUtils stub_method("getImplementationWithBlock:").with(replacementImpBlock).and_return(replacementImp);
                fakeRuntimeUtils stub_method("updateMethod:withImplemenation:").with(originalInstanceMethod).and_with(replacementImp).and_return(originalImp);
                [swizzleanObj swizzleInstanceMethod:instanceMethodSEL withReplacementImplementation:replacementImpBlock];
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
        
        context(@"#resetSwizzledInstanceMethod", ^{
            beforeEach(^{
                swizzleanObj.originalInstanceMethod = originalInstanceMethod;
                swizzleanObj.originalInstanceMethodImplementation = originalImp;
                swizzleanObj.replacementInstanceMethodImplementation = replacementImp;
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
            
            it(@"sets the isInstanceMethodSwizzled to NO", ^{
                swizzleanObj.isInstanceMethodSwizzled should_not be_truthy;
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
            beforeEach(^{
                fakeRuntimeUtils stub_method("getClassMethodWithClass:selector:").with(swizzleanObj.classToSwizzle).and_with(classMethodSEL).and_return(originalClassMethod);
                fakeRuntimeUtils stub_method("getImplementationWithBlock:").with(replacementImpBlock).and_return(replacementImp);
                fakeRuntimeUtils stub_method("updateMethod:withImplemenation:").with(originalClassMethod).and_with(replacementImp).and_return(originalImp);
                [swizzleanObj swizzleClassMethod:classMethodSEL withReplacementImplementation:replacementImpBlock];
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
        
        context(@"#resetSwizzledClassMethod", ^{
            beforeEach(^{
                swizzleanObj.originalClassMethod = originalClassMethod;
                swizzleanObj.originalClassMethodImplementation = originalImp;
                swizzleanObj.replacementClassMethodImplementation = replacementImp;
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
            
            it(@"sets the isClassMethodSwizzled to NO", ^{
                swizzleanObj.isClassMethodSwizzled should_not be_truthy;
            });
        });
    });
});

SPEC_END
