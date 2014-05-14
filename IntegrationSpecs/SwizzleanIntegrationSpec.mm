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
    
    context(@"Instance Methods", ^{
        afterEach(^{
            [swizz resetSwizzledInstanceMethod];
        });
        
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
             } should raise_exception([NSException exceptionWithName:@"Swizzlean" reason:reasonStr userInfo:nil]);
        });
    });
    
    describe(@"Class Methods", ^{
        context(@"Correct Swizzles", ^{
            afterEach(^{
                [swizz resetSwizzledClassMethod];
            });
            
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
                } should raise_exception([NSException exceptionWithName:@"Swizzlean" reason:reasonStr userInfo:nil]);
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
});

SPEC_END
