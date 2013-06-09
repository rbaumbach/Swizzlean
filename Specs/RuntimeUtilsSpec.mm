#import "RuntimeUtils.h"
#import "TestClass.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(RuntimeUtilsSpec)

describe(@"RuntimeUtils", ^{
    __block RuntimeUtils *runtimeUtils;
    __block TestClass *fakeClass;

    beforeEach(^{
        runtimeUtils = [[RuntimeUtils alloc] init];
        fakeClass = [[TestClass alloc] init];
    });
    
    context(@"#getMetaClassFromClassString:", ^{
        __block Class metaClass;
        __block Class testClass;
        
        beforeEach(^{
            metaClass = [runtimeUtils getMetaClassFromClassString:@"TestClass"];
            testClass = object_getClass(NSClassFromString(@"TestClass"));
        });
        
        it(@"returns a metaclass", ^{
            class_isMetaClass(metaClass) should be_truthy;
        });
        
        it(@"returns metaclass of class passed in", ^{
            metaClass should equal(testClass);
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
            classMethod should equal(testMethod);
        });
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
            instanceMethod should equal(testMethod);
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
            methodImplementation should_not be_nil;
        });
    });
    
    context(@"#updateMethod:withImplemenation:", ^{
        __block Method instanceMethod;
        __block IMP instanceMethodIMP;
        __block IMP oldMethodImplementation;
        
        beforeEach(^{
            instanceMethod = class_getInstanceMethod([fakeClass class], @selector(returnStringInstanceMethod:));
            instanceMethodIMP = imp_implementationWithBlock(^(id _self, NSString *inputParam){
                return @"Swizzled";
            });
            
            oldMethodImplementation = [runtimeUtils updateMethod:instanceMethod withImplemenation:instanceMethodIMP];
        });
        
        afterEach(^{
            method_setImplementation(instanceMethod, oldMethodImplementation);
        });
        
        it(@"returns a method implementation", ^{
            [fakeClass returnStringInstanceMethod:@"inputString"] should equal(@"Swizzled");
        });
    });
});

SPEC_END
