#import "SwizzleanIntegrationTests.h"
#import "Swizzlean.h"
#import "IntegrationTestClass.h"


@interface SwizzleanIntegrationTests ()

@property (strong, nonatomic) Swizzlean *swizzlean;

@end


@implementation SwizzleanIntegrationTests

- (void)setUp
{
    [super setUp];
    
    self.swizzlean = [[Swizzlean alloc] initWithClassToSwizzle:[IntegrationTestClass class]];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInstanceMethodWithVoidReturnAndNoParams
{
    __block NSString *testString;
    
    [self.swizzlean swizzleClassMethod:@selector(classMethod)
         withReplacementImplementation:^(id _self) {
             testString = @"Swizzled";
    }];
    
    [IntegrationTestClass classMethod];
    
    STAssertEqualObjects(testString, @"Swizzled", @"Method was not swizzed");
}

@end
