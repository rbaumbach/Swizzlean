#import "Swizzlean.h"


#define SWIZZLEAN_CLASS_NAME        @"Swizzlean"
#define TEMP_CLASS_METHOD_SEL       tempClassMethod
#define TEMP_INSTANCE_METHOD_SEL    tempInstanceMethod


@interface Swizzlean ()

@property(nonatomic, readwrite) Class classToSwizzle;
@property(nonatomic, readwrite) Method originalClassMethod;
@property(nonatomic, readwrite) Method originalInstanceMethod;
@property(nonatomic, readwrite) IMP originalClassMethodImplementation;
@property(nonatomic, readwrite) IMP originalInstanceMethodImplementation;
@property(nonatomic, readwrite) Method swizzleClassMethod;
@property(nonatomic, readwrite) Method swizzleInstanceMethod;

@property(copy, nonatomic, readwrite) id replacementClassMethodImplementation;
@property(copy, nonatomic, readwrite) id replacementInstanceMethodImplementation;
@property(nonatomic, readwrite) BOOL isClassMethodSwizzled;
@property(nonatomic, readwrite) BOOL isInstanceMethodSwizzled;

@end


@implementation Swizzlean

#pragma mark - Init Methods

- (id)initWithClassToSwizzle:(Class)swizzleClass
{
    self = [super init];
    if (self) {
        self.classToSwizzle = swizzleClass;
        self.isClassMethodSwizzled = NO;
        self.isInstanceMethodSwizzled = NO;
    }
    return self;
}

#pragma mark - Public Methods

- (void)swizzleClassMethod:(SEL)originalMethod withReplacementImplementation:(id)replacementImplementation
{
    self.originalClassMethod = class_getClassMethod(self.classToSwizzle, originalMethod);
    self.replacementClassMethodImplementation = replacementImplementation;
    
    Class klass = object_getClass(NSClassFromString(SWIZZLEAN_CLASS_NAME));
    IMP replacementImp = imp_implementationWithBlock(self.replacementClassMethodImplementation);
    class_addMethod(klass, @selector(TEMP_CLASS_METHOD_SEL), replacementImp, nil);
    
    self.swizzleClassMethod = class_getClassMethod(self.classToSwizzle, @selector(TEMP_CLASS_METHOD_SEL));
    self.originalClassMethodImplementation = method_setImplementation(self.originalClassMethod, replacementImp);
    self.isClassMethodSwizzled = YES;
}

- (void)swizzleInstanceMethod:(SEL)originalMethod withReplacementImplementation:(id)replacementImplementation
{
    self.originalInstanceMethod = class_getInstanceMethod(self.classToSwizzle, originalMethod);
    self.replacementInstanceMethodImplementation = replacementImplementation;
    
    IMP replacementImp = imp_implementationWithBlock(self.replacementInstanceMethodImplementation);
    class_addMethod([self class], @selector(TEMP_INSTANCE_METHOD_SEL), replacementImp, nil);
    
    self.swizzleInstanceMethod = class_getInstanceMethod(self.classToSwizzle, @selector(TEMP_INSTANCE_METHOD_SEL));
    self.originalInstanceMethodImplementation = method_setImplementation(self.originalInstanceMethod, replacementImp);
    self.isInstanceMethodSwizzled = YES;
}

- (void)unswizzleClassMethod
{
    method_setImplementation(self.originalClassMethod, self.originalClassMethodImplementation);
    
    self.originalClassMethod = nil;
    self.originalClassMethodImplementation = nil;
    self.swizzleClassMethod = nil;
    self.replacementClassMethodImplementation = nil;
    self.isClassMethodSwizzled = NO;
}

@end
