#import "Swizzlean.h"
#import "IntegrationTestClass.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SwizzleanIntegrationSpec)


describe(@"SwizzleanIntegration", ^{
    __block Swizzlean *swizz;

    beforeEach(^{
        swizz = [[Swizzlean alloc] initWithClassToSwizzle:[IntegrationTestClass class]];
    });
    
    it(@"sets isInstanceMethodSwizzled to NO", ^{
        swizz.isInstanceMethodSwizzled should be_falsy;
    });
    
    it(@"sets isClassMethodSwizzled to NO", ^{
        swizz.isClassMethodSwizzled should be_falsy;
    });
    
    it(@"sets resetWhenDeallocated to YES", ^{
        swizz.resetWhenDeallocated should be_truthy;
    });
    
    describe(@"Instance Methods", ^{
        context(@"Correct Swizzles", ^{
            it(@"correctly swizzles method with no parameters and void return type", ^{
                __block NSString *testString;
                
                [swizz swizzleInstanceMethod:@selector(instanceMethod)
               withReplacementImplementation:^(id _self) {
                   testString = @"Swizzled";
               }];
                
                IntegrationTestClass *testClass = [[IntegrationTestClass alloc] init];
                [testClass instanceMethod];
                
                testString should equal(@"Swizzled");
                
                NSString *methodNameOfSwizzledMethod = NSStringFromSelector(swizz.currentInstanceMethodSwizzled);
                
                methodNameOfSwizzledMethod should equal(@"instanceMethod");
                
                swizz.isInstanceMethodSwizzled should be_truthy;
            });
            
            it(@"correctly swizzles method with parameters and non-void return type", ^{
                IntegrationTestClass *testClass = [[IntegrationTestClass alloc] init];
                
                NSString *stringBeforeSwizzle = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                stringBeforeSwizzle should equal(@"Instance Method: A + B");
                
                [swizz swizzleInstanceMethod:@selector(instanceMethodReturnStringWithInput:andInput:)
               withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                   return [NSString stringWithFormat:@"Swizzled: %@ + %@", param1, param2];
               }];
                
                NSString *stringAfterSwizzle = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                stringAfterSwizzle should equal(@"Swizzled: A + B");
                
                NSString *methodNameOfSwizzledMethod = NSStringFromSelector(swizz.currentInstanceMethodSwizzled);
                
                methodNameOfSwizzledMethod should equal(@"instanceMethodReturnStringWithInput:andInput:");
                
                swizz.isInstanceMethodSwizzled should be_truthy;
            });
        });
        
        context(@"Incorrect Swizzles", ^{
            it(@"throws exception if method being swizzled doesn't exist", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                SEL deftonesTrackSEL = @selector(diamondEyes);
#pragma clang diagnostic pop
                
                NSString *methodName = NSStringFromSelector(deftonesTrackSEL);
                NSString *reasonStr = [NSString stringWithFormat:@"Instance method doesn't exist: %@", methodName];
                
                ^{
                    [swizz swizzleInstanceMethod:deftonesTrackSEL withReplacementImplementation:^(id self) {
                        return @"This doesn't matter";
                    }];
                } should raise_exception.with_name(@"Swizzlean").with_reason(reasonStr);
            });
            
            it(@"throws exception when attempting to reset an unswizzled instance method", ^{
                NSString *className = NSStringFromClass([IntegrationTestClass class]);
                NSString *reasonStr = [NSString stringWithFormat:@"Attempting to reset a swizzled instance method when one doesn't exist for class %@", className];
                ^{
                    [swizz resetSwizzledInstanceMethod];
                } should raise_exception.with_name(@"Swizzlean").with_reason(reasonStr);
            });
        });
    });
    
    describe(@"Class Methods", ^{
        context(@"Correct Swizzles", ^{
            it(@"correctly swizzles method with no parameters and void return type", ^{
                __block NSString *testString;
                
                [swizz swizzleClassMethod:@selector(classMethod)
            withReplacementImplementation:^(id _self) {
                testString = @"Swizzled";
            }];
                
                [IntegrationTestClass classMethod];
                
                testString should equal(@"Swizzled");
                
                NSString *methodNameOfSwizzledMethod = NSStringFromSelector(swizz.currentClassMethodSwizzled);
                
                methodNameOfSwizzledMethod should equal(@"classMethod");
                
                swizz.isClassMethodSwizzled should be_truthy;
            });
            
            it(@"correctly swizzles method with parameters and non-void return type", ^{
                NSString *stringBeforeSwizzle = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                stringBeforeSwizzle should equal(@"Class Method: A + B");
                
                [swizz swizzleClassMethod:@selector(classMethodReturnStringWithInput:andInput:)
            withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                return [NSString stringWithFormat:@"Swizzled: %@ + %@", param1, param2];
            }];
                
                NSString *stringAfterSwizzle = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                stringAfterSwizzle should equal(@"Swizzled: A + B");
                
                NSString *methodNameOfSwizzledMethod = NSStringFromSelector(swizz.currentClassMethodSwizzled);
                
                methodNameOfSwizzledMethod should equal(@"classMethodReturnStringWithInput:andInput:");
                
                swizz.isClassMethodSwizzled should be_truthy;
            });
        });
        
        context(@"Incorrect Swizzles", ^{
            it(@"throws exception if method being swizzled doesn't exist", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                SEL deftonesTrackSEL = @selector(myOwnSummer);
#pragma clang diagnostic pop
                
                NSString *methodName = NSStringFromSelector(deftonesTrackSEL);
                NSString *reasonStr = [NSString stringWithFormat:@"Class method doesn't exist: %@", methodName];
                
                ^{
                    [swizz swizzleClassMethod:deftonesTrackSEL withReplacementImplementation:^(id self) {
                        return @"This doesn't matter";
                    }];
                } should raise_exception.with_name(@"Swizzlean").with_reason(reasonStr);
            });
            
            it(@"throws exception when attempting to reset an unswizzled class method", ^{
                NSString *className = NSStringFromClass([IntegrationTestClass class]);
                NSString *reasonStr = [NSString stringWithFormat:@"Attempting to reset a swizzled class method when one doesn't exist for class %@", className];
                ^{
                    [swizz resetSwizzledClassMethod];
                } should raise_exception.with_name(@"Swizzlean").with_reason(reasonStr);
            });
        });
    });
    
    describe(@"Deallocating", ^{
        context(@"when there is only a swizzled instance method", ^{
            __block IntegrationTestClass *testClass;
            
            beforeEach(^{
                testClass = [[IntegrationTestClass alloc] init];
                
                [swizz swizzleInstanceMethod:@selector(instanceMethodReturnStringWithInput:andInput:)
               withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                   return [NSString stringWithFormat:@"Swizzled: %@ + %@", param1, param2];
               }];
            });
            
            it(@"has only a swizzled instance method before deallocating", ^{
                swizz.isInstanceMethodSwizzled should be_truthy;
                swizz.isClassMethodSwizzled should_not be_truthy;
            });
            
            it(@"resets the swizzled method when resetWhenDeallocated is set to YES", ^{
                swizz.resetWhenDeallocated = YES;
                swizz = nil;
                NSString *stringAfterDealloc = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                stringAfterDealloc should equal(@"Instance Method: A + B");
            });

            it(@"doesn't reset the swizzled method when resetWhenDeallocated is set to NO", ^{
                swizz.resetWhenDeallocated = NO;
                swizz = nil;
                NSString *stringAfterDealloc = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                stringAfterDealloc should equal(@"Swizzled: A + B");
                
                // Subsequent tests may fail unless we put the original implementation back
                // manually here. We cannot reset since swizz has been deallocated.
                swizz = [[Swizzlean alloc] initWithClassToSwizzle:[IntegrationTestClass class]];
                [swizz swizzleInstanceMethod:@selector(instanceMethodReturnStringWithInput:andInput:)
               withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                   return [NSString stringWithFormat:@"Instance Method: %@ + %@", param1, param2];
               }];
                
                swizz.resetWhenDeallocated = NO;
            });
        });
        
        context(@"when there is only a swizzled class method", ^{
            beforeEach(^{
                [swizz swizzleClassMethod:@selector(classMethodReturnStringWithInput:andInput:)
            withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                return [NSString stringWithFormat:@"Swizzled: %@ + %@", param1, param2];
            }];
            });
            
            it(@"has a only a swizzled class method before deallocating", ^{
                swizz.isInstanceMethodSwizzled should_not be_truthy;
                swizz.isClassMethodSwizzled should be_truthy;
            });
            
            it(@"resets the swizzled method when resetWhenDeallocated is set to YES", ^{
                swizz.resetWhenDeallocated = YES;
                swizz = nil;
                NSString *stringAfterDealloc = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                stringAfterDealloc should equal(@"Class Method: A + B");
            });
            
            it(@"doesn't reset the swizzled method when resetWhenDeallocated is set to NO", ^{
                swizz.resetWhenDeallocated = NO;
                swizz = nil;
                NSString *stringAfterDealloc = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                stringAfterDealloc should equal(@"Swizzled: A + B");
                
                // Subsequent tests may fail unless we put the original implementation back
                // manually here. We cannot reset since swizz has been deallocated.
                swizz = [[Swizzlean alloc] initWithClassToSwizzle:[IntegrationTestClass class]];
                [swizz swizzleClassMethod:@selector(classMethodReturnStringWithInput:andInput:)
            withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                return [NSString stringWithFormat:@"Class Method: %@ + %@", param1, param2];
            }];
                
                swizz.resetWhenDeallocated = NO;
            });
        });
        
        context(@"when both a class and instance method are swizzled", ^{
            __block IntegrationTestClass *testClass;
            
            beforeEach(^{
                testClass = [[IntegrationTestClass alloc] init];
                
                [swizz swizzleInstanceMethod:@selector(instanceMethodReturnStringWithInput:andInput:)
               withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                   return [NSString stringWithFormat:@"Swizzled Instance Method: %@ + %@", param1, param2];
               }];
                
                [swizz swizzleClassMethod:@selector(classMethodReturnStringWithInput:andInput:)
            withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                return [NSString stringWithFormat:@"Swizzled Class Method: %@ + %@", param1, param2];
            }];
            });
            
            it(@"has both a class and instance method swizzled before deallocating", ^{
                swizz.isInstanceMethodSwizzled should be_truthy;
                swizz.isClassMethodSwizzled should be_truthy;
            });
            
            it(@"resets both swizzled methods when resetWhenDeallocated is set to YES", ^{
                swizz.resetWhenDeallocated = YES;
                swizz = nil;
                NSString *instanceMethodStringAfterDealloc = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                NSString *classMethodStringAfterDealloc = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                instanceMethodStringAfterDealloc should equal(@"Instance Method: A + B");
                classMethodStringAfterDealloc should equal(@"Class Method: A + B");
            });
            
            it(@"doesn't reset either method when resetWhenDeallocated is set to NO", ^{
                swizz.resetWhenDeallocated = NO;
                swizz = nil;
                NSString *instanceMethodStringAfterDealloc = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                NSString *classMethodStringAfterDealloc = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                instanceMethodStringAfterDealloc should equal(@"Swizzled Instance Method: A + B");
                classMethodStringAfterDealloc should equal(@"Swizzled Class Method: A + B");
                
                // Subsequent tests may fail unless we put the original implementation back
                // manually here. We cannot reset since swizz has been deallocated.
                swizz = [[Swizzlean alloc] initWithClassToSwizzle:[IntegrationTestClass class]];
                [swizz swizzleInstanceMethod:@selector(instanceMethodReturnStringWithInput:andInput:)
               withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                   return [NSString stringWithFormat:@"Instance Method: %@ + %@", param1, param2];
               }];
                
                [swizz swizzleClassMethod:@selector(classMethodReturnStringWithInput:andInput:)
            withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                return [NSString stringWithFormat:@"Class Method: %@ + %@", param1, param2];
            }];
                
                swizz.resetWhenDeallocated = NO;
            });
        });
        
        context(@"when there are no swizzled methods", ^{
            it(@"doesn't have any swizzled methods before deallocating", ^{
                swizz.isInstanceMethodSwizzled should_not be_truthy;
                swizz.isClassMethodSwizzled should_not be_truthy;
            });
            
            it(@"doesn't throw an exception when resetWhenDeallocated is set to YES", ^{
                swizz.resetWhenDeallocated = YES;
                ^{
                    swizz = nil;
                } should_not raise_exception;
            });
            
            it(@"doesn't throw an exception when resetWhenDeallocated is set to NO", ^{
                swizz.resetWhenDeallocated = NO;
                ^{
                    swizz = nil;
                } should_not raise_exception;
            });
        });
    });
});

SPEC_END
