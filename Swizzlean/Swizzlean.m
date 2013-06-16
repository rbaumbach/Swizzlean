#import "Swizzlean.h"
#import "RuntimeUtils.h"


@interface Swizzlean ()

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


@implementation Swizzlean

#pragma mark - Init Methods

- (id)initWithClassToSwizzle:(Class)swizzleClass
{
    self = [super init];
    if (self) {
        self.runtimeUtils = [[RuntimeUtils alloc] init];
        self.classToSwizzle = swizzleClass;
        self.isClassMethodSwizzled = NO;
        self.isInstanceMethodSwizzled = NO;
    }
    return self;
}

#pragma mark - Public Methods

- (void)swizzleInstanceMethod:(SEL)originalMethod withReplacementImplementation:(id)replacementImplementation
{
    if (self.isInstanceMethodSwizzled) {
        return;
    }
    
    self.originalInstanceMethod = [self.runtimeUtils getInstanceMethodWithClass:self.classToSwizzle
                                                                       selector:originalMethod];
    self.replacementInstanceMethodImplementationBlock = replacementImplementation;
    self.replacementInstanceMethodImplementation = [self.runtimeUtils getImplementationWithBlock:replacementImplementation];
    self.originalInstanceMethodImplementation = [self.runtimeUtils updateMethod:self.originalInstanceMethod
                                                              withImplemenation:self.replacementInstanceMethodImplementation];
    self.currentInstanceMethodSwizzled = originalMethod;
    self.isInstanceMethodSwizzled = YES;
}

- (void)swizzleClassMethod:(SEL)originalMethod withReplacementImplementation:(id)replacementImplementation
{
    if (self.isClassMethodSwizzled) {
        return;
    }
    
    self.originalClassMethod = [self.runtimeUtils getClassMethodWithClass:self.classToSwizzle
                                                                 selector:originalMethod];
    self.replacementClassMethodImplementationBlock = replacementImplementation;
    self.replacementClassMethodImplementation = [self.runtimeUtils getImplementationWithBlock:replacementImplementation];
    self.originalClassMethodImplementation = [self.runtimeUtils updateMethod:self.originalClassMethod
                                                           withImplemenation:self.replacementClassMethodImplementation];
    self.currentClassMethodSwizzled = originalMethod;
    self.isClassMethodSwizzled = YES;
}

- (void)resetSwizzledInstanceMethod
{
    if (!self.isInstanceMethodSwizzled) {
        return;
    }
    
    [self.runtimeUtils updateMethod:self.originalInstanceMethod
                  withImplemenation:self.originalInstanceMethodImplementation];
    
    self.originalInstanceMethod = nil;
    self.originalInstanceMethodImplementation = nil;
    self.replacementInstanceMethodImplementation = nil;
    self.currentInstanceMethodSwizzled = nil;
    self.isInstanceMethodSwizzled = NO;
}

- (void)resetSwizzledClassMethod
{
    if (!self.isClassMethodSwizzled) {
        return;
    }
    
    [self.runtimeUtils updateMethod:self.originalClassMethod
                  withImplemenation:self.originalClassMethodImplementation];
    
    self.originalClassMethod = nil;
    self.originalClassMethodImplementation = nil;
    self.replacementClassMethodImplementation = nil;
    self.currentClassMethodSwizzled = nil;
    self.isClassMethodSwizzled = NO;
}

@end
