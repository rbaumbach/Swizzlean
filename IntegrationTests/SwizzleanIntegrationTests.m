#import <SenTestingKit/SenTestingKit.h>
#import "Swizzlean.h"
#import "IntegrationTestClass.h"


@interface SwizzleanIntegrationTests : SenTestCase

@property (strong, nonatomic) Swizzlean *swizzlean;

@end


@implementation SwizzleanIntegrationTests

- (void)setUp
{
    [super setUp];
    
    self.swizzlean = [[Swizzlean alloc] initWithClassToSwizzle:[IntegrationTestClass class]];
}

#pragma mark - Instance Method Testing

- (void)testIsInstanceMethodSwizzledIsNoAfterInit
{
    STAssertFalse(self.swizzlean.isInstanceMethodSwizzled, @"isInstanceMethodSwizzled should be NO before instance method swizzle");
}

- (void)testIsInstanceMethodSwizzledIsYesAfterMethodSwizzle
{
    [self.swizzlean swizzleInstanceMethod:@selector(instanceMethod)
         withReplacementImplementation:^(id _self) { }];
    STAssertTrue(self.swizzlean.isInstanceMethodSwizzled, @"isInstanceMethodSwizzled should be YES after instance method swizzle");
}

- (void)testInstanceMethodWithVoidReturnAndNoParams
{
    __block NSString *testString;
    
    [self.swizzlean swizzleInstanceMethod:@selector(instanceMethod)
         withReplacementImplementation:^(id _self) {
             testString = @"Swizzled";
    }];
    
    IntegrationTestClass *testClass = [[IntegrationTestClass alloc] init];
    [testClass instanceMethod];
    
    STAssertEqualObjects(testString, @"Swizzled", @"Instance method was not swizzled");
    
    NSString *methodNameOfSwizzledMethod = NSStringFromSelector(self.swizzlean.currentInstanceMethodSwizzled);
    STAssertEqualObjects(methodNameOfSwizzledMethod, @"instanceMethod", @"current swizzled method not stored");
    
    [self.swizzlean resetSwizzledInstanceMethod];
}

- (void)testInstanceMethodWithReturnAndParams
{
    IntegrationTestClass *testClass = [[IntegrationTestClass alloc] init];
    NSString *stringBeforeSwizzle = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
    STAssertEqualObjects(stringBeforeSwizzle, @"Instance Method: A + B", @"Incorrect integration test class string return");
    
    [self.swizzlean swizzleInstanceMethod:@selector(instanceMethodReturnStringWithInput:andInput:)
            withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                return [NSString stringWithFormat:@"Swizzled: %@ + %@", param1, param2];
            }];
    
    NSString *stringAfterSwizzle = [testClass instanceMethodReturnStringWithInput:@"A" andInput:@"B"];
    STAssertEqualObjects(stringAfterSwizzle, @"Swizzled: A + B", @"Instance method was not swizzled");
    
    NSString *methodNameOfSwizzledMethod = NSStringFromSelector(self.swizzlean.currentInstanceMethodSwizzled);
    STAssertEqualObjects(methodNameOfSwizzledMethod, @"instanceMethodReturnStringWithInput:andInput:", @"current swizzled method not stored");
    
    [self.swizzlean resetSwizzledInstanceMethod];
}

#pragma mark - Class Method Testing

- (void)testIsClassMethodSwizzledIsNoAfterInit
{
    STAssertFalse(self.swizzlean.isClassMethodSwizzled, @"isClassMethodSwizzled should be NO before class method swizzle");
}

- (void)testIsClassMethodSwizzledIsYesAfterMethodSwizzle
{
    [self.swizzlean swizzleClassMethod:@selector(classMethod)
            withReplacementImplementation:^(id _self) { }];
    STAssertTrue(self.swizzlean.isClassMethodSwizzled, @"isClassMethodSwizzled should be YES after class method swizzle");
}

- (void)testClassMethodWithVoidReturnAndNoParams
{
    __block NSString *testString;
    
    [self.swizzlean swizzleClassMethod:@selector(classMethod)
            withReplacementImplementation:^(id _self) {
                testString = @"Swizzled";
            }];
    
    [IntegrationTestClass classMethod];
    
    STAssertEqualObjects(testString, @"Swizzled", @"Class method was not swizzled");
    
    NSString *methodNameOfSwizzledMethod = NSStringFromSelector(self.swizzlean.currentClassMethodSwizzled);
    STAssertEqualObjects(methodNameOfSwizzledMethod, @"classMethod", @"current swizzled method not stored");
    
    [self.swizzlean resetSwizzledClassMethod];
}

- (void)testClassMethodWithReturnAndParams
{
    NSString *stringBeforeSwizzle = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
    STAssertEqualObjects(stringBeforeSwizzle, @"Class Method: A + B", @"Incorrect integration test class string return");
    
    [self.swizzlean swizzleClassMethod:@selector(classMethodReturnStringWithInput:andInput:)
            withReplacementImplementation:^(id _self, NSString *param1, NSString *param2) {
                return [NSString stringWithFormat:@"Swizzled: %@ + %@", param1, param2];
            }];
    
    NSString *stringAfterSwizzle = [IntegrationTestClass classMethodReturnStringWithInput:@"A" andInput:@"B"];
    STAssertEqualObjects(stringAfterSwizzle, @"Swizzled: A + B", @"Class method was not swizzled");
    
    NSString *methodNameOfSwizzledMethod = NSStringFromSelector(self.swizzlean.currentClassMethodSwizzled);
    STAssertEqualObjects(methodNameOfSwizzledMethod, @"classMethodReturnStringWithInput:andInput:", @"current swizzled method not stored");
    
    [self.swizzlean resetSwizzledClassMethod];
}

- (void)testExceptionIsThrownIfInstanceMethodBeingSwizzledDoesNotExist
{
    STAssertThrowsSpecificNamed(
                                [self.swizzlean swizzleInstanceMethod:@selector(instanceMethodDoesNotExist) withReplacementImplementation:^(id self) {
                                        return @"This doesn't matter";
                                }],
    NSException, @"Swizzlean", @"exception is not thrown for non-existant instance method");
}

- (void)testExceptionIsThrownIfClassMethodBeingSwizzledDoesNotExist
{
    STAssertThrowsSpecificNamed(
                                [self.swizzlean swizzleClassMethod:@selector(classMethodDoesNotExist) withReplacementImplementation:^(id self) {
                                        return @"This doesn't matter";
                                }],
    NSException, @"Swizzlean", @"exception is not thrown for non-existant class method");
}

@end
