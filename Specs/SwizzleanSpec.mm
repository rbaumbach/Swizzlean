#import "Swizzlean.h"
#import <objc/runtime.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface Swizzlean ()

@property(nonatomic, readonly) Method originalClassMethod;
@property(nonatomic, readwrite) IMP originalClassMethodImplementation;
@property(nonatomic, readwrite) Method swizzleClassMethod;
@property(copy, nonatomic, readwrite) id replacementClassMethodImplementation;

@end

SPEC_BEGIN(SwizzleanSpec)

describe(@"Swizzlean", ^{
    __block Swizzlean *swizzleanObj;
    __block Class testClass;

    beforeEach(^{
        testClass = [NSString class];
        swizzleanObj = [[[Swizzlean alloc] initWithClassToSwizzle:testClass] autorelease];
    });
    
    it(@"stores the class", ^{
        swizzleanObj.classToSwizzle should equal(testClass);
    });
    
    it(@"sets the isClassMethodSwizzled to NO", ^{
        swizzleanObj.isClassMethodSwizzled should_not be_truthy;
    });
    
    context(@"#swizzleClassMethod:withReplacementImplementation:", ^{
        __block SEL methodSEL;
        __block Method originalMethod;
        __block IMP originalMethodIMP;
        __block Method replacementMethod;
        
        __block IMP replacementImp;
        __block id replacementImpBlock;
        
        beforeEach(^{
            methodSEL = @selector(stringWithString:);
            originalMethod = class_getClassMethod([NSString class], @selector(stringWithString:));
            
            originalMethodIMP = [NSString methodForSelector:methodSEL];
            
            replacementImpBlock = ^(id _self, NSString *input) {
                return @"return string";
            };
            
            replacementImp = imp_implementationWithBlock(replacementImpBlock);
            Class klass = object_getClass(NSClassFromString(@"Swizzlean"));
            class_addMethod(klass, @selector(tempClassMethod:), replacementImp, "@@:@");
            replacementMethod = class_getClassMethod([Swizzlean class], @selector(tempClassMethod:));
            
            [swizzleanObj swizzleClassMethod:methodSEL withReplacementImplementation:replacementImpBlock];
        });
        
        it(@"stores the original method to be swizzled", ^{
            swizzleanObj.originalClassMethod should equal(originalMethod);
        });
        
        it(@"stores the implementation of the method swizzle", ^{
            swizzleanObj.replacementClassMethodImplementation should equal(replacementImpBlock);
        });
        
        it(@"stores the swizzled method", ^{
            swizzleanObj.swizzleClassMethod should equal(replacementMethod);
        });
        
        it(@"stores the original implementation of the original method", ^{
            swizzleanObj.originalClassMethodImplementation should equal(originalMethodIMP);
        });
        
        it(@"swaps original class method implementation with replacement implementation", ^{
            NSString *testString = [NSString stringWithString:@"test"];
            testString should equal(@"return string");
        });
        
        it(@"sets the isClassMethodSwizzled to YES", ^{
            swizzleanObj.isClassMethodSwizzled should be_truthy;
        });
    });
});

SPEC_END
