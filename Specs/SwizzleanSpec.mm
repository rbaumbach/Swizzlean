#import "Swizzlean.h"
#import <objc/runtime.h>

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
        __block id replacementImplementation;
        
        beforeEach(^{
            method = @selector(stringWithString:);
            originalMethod = class_getClassMethod([NSString class], @selector(stringWithString:));
            
            replacementImplementation = ^(id _self) {
                NSLog(@"\nHit New implementation!!!");
                return @"Uh-YAHH-YAHH";
            };
            
            replacementImp = imp_implementationWithBlock(replacementImplementation);
            Class klass = object_getClass(NSClassFromString(@"Swizzlean"));
            class_addMethod(klass, @selector(tempClassMethod), replacementImp, "@@:");
            replacementMethod = class_getClassMethod([Swizzlean class], @selector(tempClassMethod));

            [swizzlean swizzleClassMethod:method withReplacementImplementation:replacementImplementation];
        });
        
        it(@"stores the original method to be swizzled", ^{
            swizzlean.originalMethod should equal(originalMethod);
        });
        
        
        it(@"stores the implementation of the method swizzle", ^{
            swizzlean.replacementImplementation should equal(replacementImplementation);
        });
        
        it(@"stores the swizzled method", ^{
            swizzlean.swizzleMethod should equal(replacementMethod);
        });
    });
});

SPEC_END
