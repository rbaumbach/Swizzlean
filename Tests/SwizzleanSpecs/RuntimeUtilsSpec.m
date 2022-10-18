#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#import "FakeRuntimeUtils.h"
#import "TestClass.h"

SpecBegin(RuntimeUtilsSpec)

describe(@"RuntimeUtils", ^{
    __block RuntimeUtils *runtimeUtils;
    __block TestClass *fakeClass;

    beforeEach(^{
        runtimeUtils = [[RuntimeUtils alloc] init];
        fakeClass = [[TestClass alloc] init];
    });
    
    context(@"#getInstanceMethodWithClass:selector:", ^{
        __block Method instanceMethod;
        __block Method testMethod;
        
        beforeEach(^{
            instanceMethod = [runtimeUtils getInstanceMethodWithClass:[fakeClass class]
                                                             selector:@selector(returnStringInstanceMethod:)];
            testMethod = class_getInstanceMethod([fakeClass class], @selector(returnStringInstanceMethod:));
        });
        
        it(@"returns the instance method for class", ^{
            expect(instanceMethod).to.equal(testMethod);
        });
    });
    
    context(@"#getClassMethodWithClass:selector:", ^{
        __block Method classMethod;
        __block Method testMethod;
        
        beforeEach(^{
            classMethod = [runtimeUtils getClassMethodWithClass:[fakeClass class]
                                                       selector:@selector(returnStringClassMethod:)];
            testMethod = class_getClassMethod([fakeClass class], @selector(returnStringClassMethod:));
        });
        
        it(@"returns the class method for class", ^{
            expect(classMethod).to.equal(testMethod);
        });
    });
    
    context(@"#getImplementationWithBlock:", ^{
        __block IMP methodImplementation;
        
        beforeEach(^{
            methodImplementation = [runtimeUtils getImplementationWithBlock:^(id _self, NSString *inputParam) {
                return @"Swizzled";
            }];
        });
        
        it(@"returns a method implementation", ^{
            expect(methodImplementation).toNot.beNil();
        });
    });
    
    context(@"#updateMethod:withImplemenation:", ^{
        __block Method instanceMethod;
        __block IMP instanceMethodIMP;
        __block IMP oldMethodImplementation;
        
        beforeEach(^{
            instanceMethod = class_getInstanceMethod([fakeClass class], @selector(returnStringInstanceMethod:));
            instanceMethodIMP = imp_implementationWithBlock(^(id _self, NSString *inputParam) {
                return @"Swizzled";
            });
            
            oldMethodImplementation = [runtimeUtils updateMethod:instanceMethod withImplemenation:instanceMethodIMP];
        });
        
        afterEach(^{
            method_setImplementation(instanceMethod, oldMethodImplementation);
        });
        
        it(@"returns a method implementation", ^{
            expect([fakeClass returnStringInstanceMethod:@"inputString"]).to.equal(@"Swizzled");
        });
    });
});

SpecEnd
