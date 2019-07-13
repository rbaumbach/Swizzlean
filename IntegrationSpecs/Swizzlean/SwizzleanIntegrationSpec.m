#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#import "Swizzlean.h"
#import "IntegrationTestClass.h"

SpecBegin(SwizzleanIntegrationSpec)

describe(@"SwizzleanIntegration", ^{
    __block Swizzlean *swizz;

    beforeEach(^{
        swizz = [[Swizzlean alloc] initWithClassToSwizzle:[IntegrationTestClass class]];
    });
    
    it(@"sets isInstanceMethodSwizzled to NO", ^{
        expect(swizz.isInstanceMethodSwizzled).to.beFalsy();
    });
    
    it(@"sets isClassMethodSwizzled to NO", ^{
        expect(swizz.isClassMethodSwizzled).to.beFalsy();
    });
    
    it(@"sets resetWhenDeallocated to YES", ^{
        expect(swizz.resetWhenDeallocated).to.beTruthy();
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
                
                expect(testString).to.equal(@"Swizzled");
                
                NSString *methodNameOfSwizzledMethod = NSStringFromSelector(swizz.currentInstanceMethodSwizzled);
                
                expect(methodNameOfSwizzledMethod).to.equal(@"instanceMethod");
                
                expect(swizz.isInstanceMethodSwizzled).to.beTruthy();
            });
            
            it(@"correctly swizzles method with parameters and non-void return type", ^{
                IntegrationTestClass *testClass = [[IntegrationTestClass alloc] init];
                
                NSString *stringBeforeSwizzle = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                expect(stringBeforeSwizzle).to.equal(@"Instance Method: A + B");
                
                [swizz swizzleInstanceMethod:@selector(instanceMethodReturnStringWithInput:andInput:)
               withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                   return [NSString stringWithFormat:@"Swizzled: %@ + %@", param1, param2];
               }];
                
                NSString *stringAfterSwizzle = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                expect(stringAfterSwizzle).to.equal(@"Swizzled: A + B");
                
                NSString *methodNameOfSwizzledMethod = NSStringFromSelector(swizz.currentInstanceMethodSwizzled);
                
                expect(methodNameOfSwizzledMethod).to.equal(@"instanceMethodReturnStringWithInput:andInput:");
                
                expect(swizz.isInstanceMethodSwizzled).to.beTruthy();
            });
        });
        
        context(@"Incorrect Swizzles", ^{
            it(@"throws exception if method being swizzled doesn't exist", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                SEL deftonesTrackSEL = @selector(diamondEyes);
#pragma clang diagnostic pop
                
                expect(^{ [swizz swizzleInstanceMethod:deftonesTrackSEL withReplacementImplementation:^(id self) {
                                 return @"This doesn't matter"; }]; }).to.raise(@"Swizzlean");
            });
            
            it(@"throws exception when attempting to reset an unswizzled instance method", ^{
                expect(^{ [swizz resetSwizzledInstanceMethod]; }).to.raise(@"Swizzlean");
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
                
                expect(testString).to.equal(@"Swizzled");
                
                NSString *methodNameOfSwizzledMethod = NSStringFromSelector(swizz.currentClassMethodSwizzled);
                
                expect(methodNameOfSwizzledMethod).to.equal(@"classMethod");
                
                expect(swizz.isClassMethodSwizzled).to.beTruthy();
            });
            
            it(@"correctly swizzles method with parameters and non-void return type", ^{
                NSString *stringBeforeSwizzle = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                expect(stringBeforeSwizzle).to.equal(@"Class Method: A + B");
                
                [swizz swizzleClassMethod:@selector(classMethodReturnStringWithInput:andInput:)
            withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                return [NSString stringWithFormat:@"Swizzled: %@ + %@", param1, param2];
            }];
                
                NSString *stringAfterSwizzle = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                expect(stringAfterSwizzle).to.equal(@"Swizzled: A + B");
                
                NSString *methodNameOfSwizzledMethod = NSStringFromSelector(swizz.currentClassMethodSwizzled);
                
                expect(methodNameOfSwizzledMethod).to.equal(@"classMethodReturnStringWithInput:andInput:");
                
                expect(swizz.isClassMethodSwizzled).to.beTruthy();
            });
        });
        
        context(@"Incorrect Swizzles", ^{
            it(@"throws exception if method being swizzled doesn't exist", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                SEL deftonesTrackSEL = @selector(myOwnSummer);
#pragma clang diagnostic pop
                
                expect(^{ [swizz swizzleClassMethod:deftonesTrackSEL withReplacementImplementation:^(id self) {
                                 return @"This doesn't matter"; }]; }).to.raise(@"Swizzlean");
            });
            
            it(@"throws exception when attempting to reset an unswizzled class method", ^{
                expect(^{ [swizz resetSwizzledClassMethod]; }).to.raise(@"Swizzlean");
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
                expect(swizz.isInstanceMethodSwizzled).to.beTruthy();
                expect(swizz.isClassMethodSwizzled).toNot.beTruthy();
            });
            
            it(@"resets the swizzled method when resetWhenDeallocated is set to YES", ^{
                swizz.resetWhenDeallocated = YES;
                swizz = nil;
                NSString *stringAfterDealloc = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                expect(stringAfterDealloc).to.equal(@"Instance Method: A + B");
            });

            it(@"doesn't reset the swizzled method when resetWhenDeallocated is set to NO", ^{
                swizz.resetWhenDeallocated = NO;
                swizz = nil;
                NSString *stringAfterDealloc = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                expect(stringAfterDealloc).to.equal(@"Swizzled: A + B");
                
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
                expect(swizz.isInstanceMethodSwizzled).toNot.beTruthy();
                expect(swizz.isClassMethodSwizzled).to.beTruthy();
            });
            
            it(@"resets the swizzled method when resetWhenDeallocated is set to YES", ^{
                swizz.resetWhenDeallocated = YES;
                swizz = nil;
                NSString *stringAfterDealloc = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                expect(stringAfterDealloc).to.equal(@"Class Method: A + B");
            });
            
            it(@"doesn't reset the swizzled method when resetWhenDeallocated is set to NO", ^{
                swizz.resetWhenDeallocated = NO;
                swizz = nil;
                NSString *stringAfterDealloc = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                expect(stringAfterDealloc).to.equal(@"Swizzled: A + B");
                
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
                expect(swizz.isInstanceMethodSwizzled).to.beTruthy();
                expect(swizz.isClassMethodSwizzled).to.beTruthy();
            });
            
            it(@"resets both swizzled methods when resetWhenDeallocated is set to YES", ^{
                swizz.resetWhenDeallocated = YES;
                swizz = nil;
                NSString *instanceMethodStringAfterDealloc = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                NSString *classMethodStringAfterDealloc = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                expect(instanceMethodStringAfterDealloc).to.equal(@"Instance Method: A + B");
                expect(classMethodStringAfterDealloc).to.equal(@"Class Method: A + B");
            });
            
            it(@"doesn't reset either method when resetWhenDeallocated is set to NO", ^{
                swizz.resetWhenDeallocated = NO;
                swizz = nil;
                NSString *instanceMethodStringAfterDealloc = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
                NSString *classMethodStringAfterDealloc = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
                
                expect(instanceMethodStringAfterDealloc).to.equal(@"Swizzled Instance Method: A + B");
                expect(classMethodStringAfterDealloc).to.equal(@"Swizzled Class Method: A + B");
                
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
                expect(swizz.isInstanceMethodSwizzled).toNot.beTruthy();
                expect(swizz.isClassMethodSwizzled).toNot.beTruthy();
            });
            
            it(@"doesn't throw an exception when resetWhenDeallocated is set to YES", ^{
                swizz.resetWhenDeallocated = YES;

                expect(^{ swizz = nil; }).toNot.raiseAny();
            });
            
            it(@"doesn't throw an exception when resetWhenDeallocated is set to NO", ^{
                swizz.resetWhenDeallocated = NO;
                
                expect(^{ swizz = nil; }).toNot.raiseAny();
            });
        });
    });
});

SpecEnd
