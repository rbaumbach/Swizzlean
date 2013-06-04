#import <objc/runtime.h>
#import "Swizzlean.h"
#import "TestClass.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface Swizzlean ()

@property(nonatomic, readwrite) Method originalClassMethod;
@property(nonatomic, readwrite) Method originalInstanceMethod;
@property(nonatomic, readwrite) IMP originalClassMethodImplementation;
@property(nonatomic, readwrite) IMP originalInstanceMethodImplementation;
@property(nonatomic, readwrite) Method swizzleClassMethod;
@property(nonatomic, readwrite) Method swizzleInstanceMethod;


@property(copy, nonatomic, readwrite) id replacementClassMethodImplementation;
@property(copy, nonatomic, readwrite) id replacementInstanceMethodImplementation;

@property(nonatomic, readwrite) BOOL isClassMethodSwizzled;
@property(nonatomic, readwrite) BOOL isInstanceMethodSwizzled;

@end


SPEC_BEGIN(SwizzleanSpec)

describe(@"Swizzlean", ^{
    __block Swizzlean *swizzleanObj;
    __block Class testClass;
    
    beforeEach(^{
        testClass = [TestClass class];
        swizzleanObj = [[[Swizzlean alloc] initWithClassToSwizzle:testClass] autorelease];
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
    
    describe(@"Class method swizzling", ^{
        __block SEL classMethodSEL;
        __block Method originalClassMethod;
        __block IMP originalClassMethodIMP;
        __block Method swizzleReplacementClassMethod;
        __block id replacementImpBlock;
        
        beforeEach(^{
            classMethodSEL = @selector(returnString:);
            originalClassMethod = class_getClassMethod([TestClass class], classMethodSEL);
            originalClassMethodIMP = [TestClass methodForSelector:classMethodSEL];
            replacementImpBlock = ^(id _self, NSString *input) {
                return [NSString stringWithFormat:@"return with input: %@",input];
            };
            
            IMP replacementImp = imp_implementationWithBlock(replacementImpBlock);
            Class klass = object_getClass(NSClassFromString(@"Swizzlean"));
            class_addMethod(klass, @selector(tempClassMethod), replacementImp, nil);
            swizzleReplacementClassMethod = class_getClassMethod(swizzleanObj.classToSwizzle, @selector(tempClassMethod));
        });
        
        afterEach(^{
            method_setImplementation(originalClassMethod, originalClassMethodIMP);
        });
        
        context(@"#swizzleClassMethod:withReplacementImplementation:", ^{
            beforeEach(^{
                [swizzleanObj swizzleClassMethod:classMethodSEL withReplacementImplementation:replacementImpBlock];
            });
            
            it(@"stores the original method to be swizzled", ^{
                swizzleanObj.originalClassMethod should equal(originalClassMethod);
            });
            
            it(@"stores the implementation of the method swizzle", ^{
                swizzleanObj.replacementClassMethodImplementation should equal(replacementImpBlock);
            });
            
            it(@"stores the swizzled method", ^{
                swizzleanObj.swizzleClassMethod should equal(swizzleReplacementClassMethod);
            });
            
            it(@"stores the original implementation of the original method", ^{
                swizzleanObj.originalClassMethodImplementation should equal(originalClassMethodIMP);
            });
            
            it(@"swaps original class method implementation with replacement implementation", ^{
                [TestClass returnString:@"inputTest"] should equal(@"return with input: inputTest");
            });
            
            it(@"sets the isClassMethodSwizzled to YES", ^{
                swizzleanObj.isClassMethodSwizzled should be_truthy;
            });
        });
        
        context(@"#unswizzleClassMethod", ^{
            beforeEach(^{
                swizzleanObj.originalClassMethod = originalClassMethod;
                swizzleanObj.originalClassMethodImplementation = originalClassMethodIMP;
                swizzleanObj.replacementClassMethodImplementation = replacementImpBlock;
                swizzleanObj.swizzleClassMethod = swizzleReplacementClassMethod;
                swizzleanObj.isClassMethodSwizzled = YES;
                
                [swizzleanObj unswizzleClassMethod];
            });
            
            it(@"unswizzles the class method (sets original implementation of class method)", ^{
                [TestClass returnString:@"inputTest"] should equal(@"inputTest");
            });
            
            it(@"resets class method", ^{
                swizzleanObj.originalClassMethod should be_nil;
                swizzleanObj.originalClassMethodImplementation should be_nil;
            });
            
            it(@"resets class method swizzle and replacement class method implementation", ^{
                swizzleanObj.swizzleClassMethod should be_nil;
                swizzleanObj.replacementClassMethodImplementation should be_nil;
            });
            
            it(@"sets the isClassMethodSwizzled to NO", ^{
                swizzleanObj.isClassMethodSwizzled should_not be_truthy;
            });
        });
    });
    
    describe(@"Instance method swizzling", ^{
        __block SEL instanceMethodSEL;
        __block Method originalInstanceMethod;
        __block IMP originalInstanceMethodIMP;
        __block Method swizzleReplacementInstanceMethod;
        __block id replacementImpBlock;
        
        beforeEach(^{
            instanceMethodSEL = @selector(returnString:);
            originalInstanceMethod = class_getInstanceMethod(testClass, instanceMethodSEL);
            originalInstanceMethodIMP = [TestClass methodForSelector:instanceMethodSEL];
            replacementImpBlock = ^(id _self, NSString *input) {
                return [NSString stringWithFormat:@"return with input: %@",input];
            };

            IMP replacementImp = imp_implementationWithBlock(replacementImpBlock);
            class_addMethod([TestClass class], @selector(tempInstanceMethod), replacementImp, "@:@");
            swizzleReplacementInstanceMethod = class_getInstanceMethod(swizzleanObj.classToSwizzle, @selector(tempInstanceMethod));
        });
        
        afterEach(^{
            method_setImplementation(originalInstanceMethod, originalInstanceMethodIMP);
        });
        
        context(@"#swizzleInstanceMethod:withReplacementImplementation:", ^{
            beforeEach(^{
                [swizzleanObj swizzleInstanceMethod:instanceMethodSEL withReplacementImplementation:replacementImpBlock];
            });
            
            it(@"stores the original method to be swizzled", ^{
                swizzleanObj.originalInstanceMethod should equal(originalInstanceMethod);
            });
            
            it(@"stores the implementation of the method swizzle", ^{
                swizzleanObj.replacementInstanceMethodImplementation should equal(replacementImpBlock);
            });

            it(@"stores the swizzled method", ^{
                swizzleanObj.swizzleInstanceMethod should equal(swizzleReplacementInstanceMethod);
            });

            it(@"stores the original implementation of the original method", ^{
                swizzleanObj.originalInstanceMethodImplementation should equal(originalInstanceMethodIMP);
            });

            it(@"swaps original class method implementation with replacement implementation", ^{
                TestClass *testClass = [[TestClass alloc] init];
                [testClass returnString:@"inputTest"] should equal(@"return with input: inputTest");
            });

            it(@"sets the isClassMethodSwizzled to YES", ^{
                swizzleanObj.isInstanceMethodSwizzled should be_truthy;
            });
        });
    });
});

SPEC_END
