#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#import "Swizzlean.h"
#import "TestClass.h"
#import "RuntimeUtils.h"
#import "FakeRuntimeUtils.h"

@interface Swizzlean (Specs)

@property(nonatomic, readwrite) RuntimeUtils *runtimeUtils;

@property(nonatomic, readwrite) Class classToSwizzle;

@property(nonatomic, readwrite) Method originalInstanceMethod;
@property(nonatomic, readwrite) Method originalClassMethod;
@property(nonatomic, readwrite) IMP originalInstanceMethodImplementation;
@property(nonatomic, readwrite) IMP originalClassMethodImplementation;

@property(copy, nonatomic, readwrite) id replacementInstanceMethodImplementationBlock;
@property(copy, nonatomic, readwrite) id replacementClassMethodImplementationBlock;
@property(nonatomic, readwrite) IMP replacementInstanceMethodImplementation;
@property(nonatomic, readwrite) IMP replacementClassMethodImplementation;

@property(nonatomic, readwrite) SEL currentInstanceMethodSwizzled;
@property(nonatomic, readwrite) SEL currentClassMethodSwizzled;

@property(nonatomic, readwrite) BOOL isInstanceMethodSwizzled;
@property(nonatomic, readwrite) BOOL isClassMethodSwizzled;

@end

SpecBegin(SwizzleanSpec)

describe(@"Swizzlean", ^{
    __block Swizzlean *swizzleanObj;
    __block Class testClass;
    __block FakeRuntimeUtils *fakeRuntimeUtils;
    
    beforeEach(^{
        testClass = [TestClass class];
        swizzleanObj = [[Swizzlean alloc] initWithClassToSwizzle:testClass];
        
        fakeRuntimeUtils = [[FakeRuntimeUtils alloc] init];
        swizzleanObj.runtimeUtils = fakeRuntimeUtils;
    });
    
    it(@"has an instance of RuntimeUtils", ^{
        expect(swizzleanObj.runtimeUtils).toNot.beNil();
    });

    it(@"stores the class", ^{
        expect(swizzleanObj.classToSwizzle).to.equal(testClass);
    });
    
    it(@"sets the isClassMethodSwizzled to NO", ^{
        expect(swizzleanObj.isClassMethodSwizzled).toNot.beTruthy();
    });
    
    it(@"sets the isInstanceMethodSwizzled to NO", ^{
        expect(swizzleanObj.isInstanceMethodSwizzled).toNot.beTruthy();
    });
    
    it(@"sets resetWhenDeallocated to YES", ^{
        expect(swizzleanObj.resetWhenDeallocated).to.beTruthy();
    });
    
    it(@"has a currentInstanceMethodSwizzled: that is nil", ^{
        expect(swizzleanObj.currentInstanceMethodSwizzled).to.beNil();
    });
    
    it(@"has a currentClassMethodSwizzled: that is nil", ^{
        expect(swizzleanObj.currentClassMethodSwizzled).to.beNil();
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
            describe(@"when instance method doesn't exist", ^{
                __block SEL tacoMethodSEL;

                beforeEach(^{
                    swizzleanObj.isInstanceMethodSwizzled = NO;
                    
                    fakeRuntimeUtils.shouldReturnNULLForGetInstanceMethod = YES;
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                    tacoMethodSEL = @selector(tacosAreYummy:);
#pragma clang diagnostic pop
                });
                
                it(@"throws an exception", ^{
                    expect(^{ [swizzleanObj swizzleInstanceMethod:tacoMethodSEL withReplacementImplementation:replacementImpBlock]; }).to.raise(@"Swizzlean");
                });
            });
            
            describe(@"when instance method hasn't been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isInstanceMethodSwizzled = NO;
                    [swizzleanObj swizzleInstanceMethod:instanceMethodSEL
                          withReplacementImplementation:replacementImpBlock];
                });
                
                it(@"stores the selector of original method", ^{
                    expect(fakeRuntimeUtils.getInstanceMethodClass).to.equal(swizzleanObj.classToSwizzle);
                    expect(fakeRuntimeUtils.getInstanceMethodSelector).to.equal(instanceMethodSEL);
                    expect(swizzleanObj.currentInstanceMethodSwizzled).to.equal(instanceMethodSEL);
                });
                
                it(@"stores the original instance method to be swizzled", ^{
                    expect(swizzleanObj.originalInstanceMethod).to.equal(originalInstanceMethod);
                });
                
                it(@"stores the replacement implementation block", ^{
                    expect(fakeRuntimeUtils.getImplementationBlock).to.equal(replacementImpBlock);
                });
                
                it(@"stores the replacement implementation from block", ^{
                    IMP fakeBlockImp = fakeRuntimeUtils.getImplementationBlockImp;
                    expect(swizzleanObj.replacementInstanceMethodImplementation).to.equal(fakeBlockImp);
                });
                
                it(@"stores the original instance method implementation", ^{
                    IMP fakeBlockImp = fakeRuntimeUtils.getImplementationBlockImp;
                    expect(fakeRuntimeUtils.updateMethodImplementation).to.equal(fakeBlockImp);
                    expect(swizzleanObj.originalInstanceMethodImplementation).to.equal(fakeRuntimeUtils.updateMethodSetImplementation);
                });
                
                it(@"sets isInstanceMethodSwizzled to YES", ^{
                    expect(swizzleanObj.isInstanceMethodSwizzled).to.beTruthy();
                });
            });
            
            describe(@"when instance method has already been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isInstanceMethodSwizzled = YES;
                    
                    [swizzleanObj swizzleInstanceMethod:instanceMethodSEL
                          withReplacementImplementation:replacementImpBlock];
                });

                it(@"immediately returns", ^{
                    BOOL updateMethodImplementationHasBeenCalled = ((FakeRuntimeUtils *)swizzleanObj.runtimeUtils).updateMethodImplementationHasBeenCalled;
                    expect(updateMethodImplementationHasBeenCalled).to.beFalsy();
                });
            });
        });
        
        context(@"#resetSwizzledInstanceMethod", ^{
            describe(@"when instance method has been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isInstanceMethodSwizzled = YES;
                    swizzleanObj.originalInstanceMethod = originalInstanceMethod;
                    swizzleanObj.originalInstanceMethodImplementation = originalImp;
                    swizzleanObj.replacementInstanceMethodImplementation = replacementImp;
                    swizzleanObj.currentInstanceMethodSwizzled = instanceMethodSEL;
                    
                    [swizzleanObj resetSwizzledInstanceMethod];
                });
                
                it(@"unswizzles the instance method (sets original implementation of instance method)", ^{
                    expect(fakeRuntimeUtils.updateMethod).to.equal(originalInstanceMethod);
                    expect(fakeRuntimeUtils.updateMethodImplementation).to.equal(originalImp);
                });
                
                it(@"resets instance method", ^{
                    expect(swizzleanObj.originalInstanceMethod).to.beNil();
                    expect(swizzleanObj.originalInstanceMethodImplementation).to.beNil();
                });
                
                it(@"resets replacement instance method implementation", ^{
                    expect(swizzleanObj.replacementInstanceMethodImplementation).to.beNil();
                });
                
                it(@"resets the SEL of the original instance method swizzled", ^{
                    expect(swizzleanObj.currentInstanceMethodSwizzled).to.beNil();
                });
                
                it(@"sets the isInstanceMethodSwizzled to NO", ^{
                    expect(swizzleanObj.isInstanceMethodSwizzled).toNot.beTruthy();
                });
            });
            
            describe(@"when instance method has not been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.classToSwizzle = [NSObject class];
                    swizzleanObj.isInstanceMethodSwizzled = NO;
                });
                
                it(@"throws an exception", ^{
                    expect(^{ [swizzleanObj resetSwizzledInstanceMethod]; }).to.raise(@"Swizzlean");

                });
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
            describe(@"when class method doesn't exist", ^{
                __block SEL burritoMethodSEL;

                beforeEach(^{
                    swizzleanObj.isClassMethodSwizzled = NO;
                    
                    ((FakeRuntimeUtils *)swizzleanObj.runtimeUtils).shouldReturnNULLForGetClassMethod = YES;
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                    burritoMethodSEL = @selector(returnStringInstanceMethod:);
#pragma clang diagnostic pop
                });
                
                it(@"throws an exception", ^{
                  expect(^{ [swizzleanObj swizzleClassMethod:burritoMethodSEL withReplacementImplementation:replacementImpBlock]; }).to.raise(@"Swizzlean");
                });
            });
            
            describe(@"when class method hasn't been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isClassMethodSwizzled = NO;
                    [swizzleanObj swizzleClassMethod:classMethodSEL withReplacementImplementation:replacementImpBlock];
                });
                
                it(@"stores the selector of class method", ^{
                    expect(fakeRuntimeUtils.getClassMethodClass).to.equal(swizzleanObj.classToSwizzle);
                    expect(fakeRuntimeUtils.getClassMethodSelector).to.equal(classMethodSEL);
                    expect(swizzleanObj.currentClassMethodSwizzled).to.equal(classMethodSEL);
                });
                
                it(@"stores the original class method to be swizzled", ^{
                    expect(swizzleanObj.originalClassMethod).to.equal(originalClassMethod);
                });
                
                it(@"stores the replacement implementation block", ^{
                    expect(fakeRuntimeUtils.getImplementationBlock).to.equal(replacementImpBlock);
                    expect(swizzleanObj.replacementClassMethodImplementationBlock).to.equal(replacementImpBlock);
                });
                
                it(@"stores the replacement implementation from block", ^{
                    IMP fakeBlockImp = fakeRuntimeUtils.getImplementationBlockImp;
                    expect(swizzleanObj.replacementClassMethodImplementation).to.equal(fakeBlockImp);
                });
                
                it(@"stores the original class method implementation", ^{
                    IMP fakeBlockImp = fakeRuntimeUtils.getImplementationBlockImp;
                    expect(fakeRuntimeUtils.updateMethodImplementation).to.equal(fakeBlockImp);
                    expect(swizzleanObj.originalClassMethodImplementation).to.equal(fakeRuntimeUtils.updateMethodSetImplementation);
                });
                
                it(@"sets isInstanceMethodSwizzled to YES", ^{
                    expect(swizzleanObj.isClassMethodSwizzled).to.beTruthy();
                });
            });
            
            describe(@"when class method has already been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isClassMethodSwizzled = YES;
                    [swizzleanObj swizzleClassMethod:classMethodSEL withReplacementImplementation:replacementImpBlock];
                });
                
                it(@"immediately returns", ^{
                    BOOL updateMethodImplementationHasBeenCalled = ((FakeRuntimeUtils *)swizzleanObj.runtimeUtils).updateMethodImplementationHasBeenCalled;
                    expect(updateMethodImplementationHasBeenCalled).to.beFalsy();
                });
            });
        });
        
        context(@"#resetSwizzledClassMethod", ^{
            describe(@"when class method has already been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.isClassMethodSwizzled = YES;
                    swizzleanObj.originalClassMethod = originalClassMethod;
                    swizzleanObj.originalClassMethodImplementation = originalImp;
                    swizzleanObj.replacementClassMethodImplementation = replacementImp;
                    swizzleanObj.currentClassMethodSwizzled = classMethodSEL;
                    [swizzleanObj resetSwizzledClassMethod];
                });
                
                it(@"unswizzles the class method (sets original implementation of class method)", ^{
                    expect(fakeRuntimeUtils.updateMethod).to.equal(originalClassMethod);
                    expect(fakeRuntimeUtils.updateMethodImplementation).to.equal(originalImp);
                });
                
                it(@"resets class method", ^{
                    expect(swizzleanObj.originalClassMethod).to.beNil();
                    expect(swizzleanObj.originalClassMethodImplementation).to.beNil();
                });
                
                it(@"resets replacement class method implementation", ^{
                    expect(swizzleanObj.replacementClassMethodImplementation).to.beNil();
                });
                
                it(@"resets the SEL of the original class method swizzled", ^{
                    expect(swizzleanObj.currentClassMethodSwizzled).to.beNil();
                });
                
                it(@"sets the isClassMethodSwizzled to NO", ^{
                    expect(swizzleanObj.isClassMethodSwizzled).toNot.beTruthy();
                });
            });
            
            describe(@"when class method has not been swizzled", ^{
                beforeEach(^{
                    swizzleanObj.classToSwizzle = [NSObject class];
                    swizzleanObj.isClassMethodSwizzled = NO;
                });
                
                it(@"throws an exception", ^{
                    expect(^{ [swizzleanObj resetSwizzledClassMethod]; }).to.raise(@"Swizzlean");
                });
            });
        });
    });
});

SpecEnd
