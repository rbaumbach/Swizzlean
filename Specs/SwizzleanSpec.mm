#import "Swizzlean.h"
#import <objc/runtime.h>

#define TEMP_CLASS_METHOD tempClassMethod


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface Swizzlean ()

@property(nonatomic, readonly) Method originalMethod;
@property(nonatomic, readwrite) Method swizzleMethod;
@property(copy, nonatomic, readwrite) id replacementImplementation;

@end

SPEC_BEGIN(SwizzleanSpec)

describe(@"Swizzlean", ^{
    __block Swizzlean *swizzlean;
    __block Class testClass;

    beforeEach(^{
        testClass = [NSString class];
        swizzlean = [[Swizzlean alloc] initWithClassToSwizzle:testClass];
    });
    
    it(@"stores the class", ^{
        swizzlean.classToSwizzle should equal(testClass);
    });
    
    describe(@"#swizzleClassMethod:withReplacementImplementation:", ^{
        __block SEL method;          
        __block Method originalMethod;
        __block Method replacementMethod;
       
        __block IMP replacementImp;
        __block id replacementImpBlock;
        
        beforeEach(^{
            method = @selector(stringWithString:);
            originalMethod = class_getClassMethod([NSString class], @selector(stringWithString:));
            
            replacementImpBlock = ^(id _self) {
                NSLog(@"\nHit New implementation!!!");
                return @"Uh-YAHH-YAHH";
            };
            
            replacementImp = imp_implementationWithBlock(replacementImpBlock);
            class_addMethod([Swizzlean class], @selector(TEMP_CLASS_METHOD), replacementImp, "@@:");
            replacementMethod = class_getClassMethod([Swizzlean class], @selector(TEMP_CLASS_METHOD));

            [swizzlean swizzleClassMethod:method withReplacementImplementation:replacementImpBlock];
        });
        
        it(@"stores the original method to be swizzled", ^{
            swizzlean.originalMethod should equal(originalMethod);
        });
        
        
        it(@"stores the implementation of the method swizzle", ^{
            swizzlean.replacementImplementation should equal(replacementImpBlock);
        });
        
        it(@"stores the swizzled method", ^{
            swizzlean.swizzleMethod should equal(replacementMethod);
        });
    });
});

SPEC_END
