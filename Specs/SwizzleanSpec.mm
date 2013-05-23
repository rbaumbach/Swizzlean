#import "Swizzlean.h"
#import <objc/runtime.h>

#define TEMP_CLASS_METHOD           tempClassMethod:

#define TEST_CLASS                  NSString
#define TEST_CLASS_METHOD_SEL       stringWithString:
#define TEST_CLASS_METHOD_ENCODING  "@@:"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface Swizzlean ()

@property(nonatomic, readonly) Method originalMethod;
@property(nonatomic, readwrite) Method swizzleMethod;
@property(copy, nonatomic, readwrite) id replacementImplementation;

@end

SPEC_BEGIN(SwizzleanSpec)

describe(@"Swizzlean", ^{
    __block Swizzlean *swizzleanObj;
    __block Class testClass;

    beforeEach(^{
        testClass = [TEST_CLASS class];
        swizzleanObj = [[[Swizzlean alloc] initWithClassToSwizzle:testClass] autorelease];
    });
    
    it(@"stores the class", ^{
        swizzleanObj.classToSwizzle should equal(testClass);
    });
    
    describe(@"#swizzleClassMethod:withReplacementImplementation:", ^{
        __block SEL methodSEL;
        __block Method originalMethod;
        __block Method replacementMethod;
       
        __block IMP replacementImp;
        __block id replacementImpBlock;
        
        beforeEach(^{
            methodSEL = @selector(TEST_CLASS_METHOD_SEL);
            originalMethod = class_getClassMethod([TEST_CLASS class], @selector(TEST_CLASS_METHOD_SEL));
            
            replacementImpBlock = ^(id _self) {
                NSLog(@"\nHit New implementation!!!");
                return @"Uh-YAHH-YAHH";
            };
            
            replacementImp = imp_implementationWithBlock(replacementImpBlock);
            Class klass = object_getClass(NSClassFromString(@"Swizzlean"));
            class_addMethod(klass, @selector(TEMP_CLASS_METHOD), replacementImp, TEST_CLASS_METHOD_ENCODING);
            replacementMethod = class_getClassMethod([Swizzlean class], @selector(TEMP_CLASS_METHOD));

            [swizzleanObj swizzleClassMethod:methodSEL withReplacementImplementation:replacementImpBlock];
        });
        
        it(@"stores the original method to be swizzled", ^{
            swizzleanObj.originalMethod should equal(originalMethod);
        });
        
        it(@"stores the implementation of the method swizzle", ^{
            swizzleanObj.replacementImplementation should equal(replacementImpBlock);
        });
        
        it(@"stores the swizzled method", ^{
            swizzleanObj.swizzleMethod should equal(replacementMethod);
        });
    });
});

SPEC_END
