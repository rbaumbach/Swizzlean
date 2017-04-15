#import "RuntimeUtils.h"

@interface FakeRuntimeUtils : RuntimeUtils

@property(nonatomic) BOOL shouldReturnNULLForGetInstanceMethod;
@property(nonatomic) Class getInstanceMethodClass;
@property(nonatomic) SEL getInstanceMethodSelector;

@property(nonatomic) BOOL shouldReturnNULLForGetClassMethod;
@property(nonatomic) Class getClassMethodClass;
@property(nonatomic) SEL getClassMethodSelector;

@property(strong, nonatomic) id getImplementationBlock;
@property(nonatomic) IMP getImplementationBlockImp;

@property(nonatomic) Method updateMethod;
@property(nonatomic) IMP updateMethodImplementation;
@property(nonatomic) IMP updateMethodSetImplementation;
@property(nonatomic) BOOL updateMethodImplementationHasBeenCalled;

@end
