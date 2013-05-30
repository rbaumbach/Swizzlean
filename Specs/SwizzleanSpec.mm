#import <objc/runtime.h>
#import "Swizzlean.h"
#import "TestClass.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface Swizzlean ()

@property(nonatomic, readwrite) Method originalClassMethod;
@property(nonatomic, readwrite) IMP originalClassMethodImplementation;
@property(nonatomic, readwrite) Method swizzleClassMethod;
@property(copy, nonatomic, readwrite) id replacementClassMethodImplementation;
@property(nonatomic, readwrite) BOOL isClassMethodSwizzled;

@end

SPEC_BEGIN(SwizzleanSpec)

describe(@"Swizzlean", ^{
    __block Swizzlean *swizzleanObj;
    __block Class testClass;
    __block SEL methodSEL;
    __block Method originalClassMethod;
    __block IMP originalClassMethodIMP;
    __block Method swizzleReplacementMethod;
    __block id replacementImpBlock;

    beforeEach(^{
        testClass = [TestClass class];
        swizzleanObj = [[[Swizzlean alloc] initWithClassToSwizzle:testClass] autorelease];
        methodSEL = @selector(returnString:);
        originalClassMethod = class_getClassMethod([TestClass class], methodSEL);
        originalClassMethodIMP = [TestClass methodForSelector:methodSEL];
        replacementImpBlock = ^(id _self, NSString *input) {
            return [NSString stringWithFormat:@"return with input: %@",input];
        };
        
        IMP replacementImp = imp_implementationWithBlock(replacementImpBlock);
        Class klass = object_getClass(NSClassFromString(@"Swizzlean"));
        class_addMethod(klass, @selector(tempClassMethod:), replacementImp, "@@:@");
        swizzleReplacementMethod = class_getClassMethod([Swizzlean class], @selector(tempClassMethod:));
    });
    
    afterEach(^{
        method_setImplementation(originalClassMethod, originalClassMethodIMP);
    });

    it(@"stores the class", ^{
        swizzleanObj.classToSwizzle should equal(testClass);
    });
    
    it(@"sets the isClassMethodSwizzled to NO", ^{
        swizzleanObj.isClassMethodSwizzled should_not be_truthy;
    });
    
    context(@"#swizzleClassMethod:withReplacementImplementation:", ^{
        beforeEach(^{
            [swizzleanObj swizzleClassMethod:methodSEL withReplacementImplementation:replacementImpBlock];
        });

        it(@"stores the original method to be swizzled", ^{
            swizzleanObj.originalClassMethod should equal(originalClassMethod);
        });
        
        it(@"stores the implementation of the method swizzle", ^{
            swizzleanObj.replacementClassMethodImplementation should equal(replacementImpBlock);
        });
        
        it(@"stores the swizzled method", ^{
            swizzleanObj.swizzleClassMethod should equal(swizzleReplacementMethod);
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
            swizzleanObj.swizzleClassMethod = swizzleReplacementMethod;
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

SPEC_END
