#import "Swizzlean.h"


#define SWIZZLEAN_CLASS_NAME        @"Swizzlean"

#define TEMP_CLASS_METHOD_SEL       tempClassMethod:
#define TEMP_CLASS_METHOD_ENCODING  "@@:@"

@interface Swizzlean ()

@property(nonatomic, readwrite) Class classToSwizzle;
@property(nonatomic, readwrite) Method originalClassMethod;
@property(nonatomic, readwrite) IMP originalClassMethodImplementation;
@property(nonatomic, readwrite) Method swizzleClassMethod;
@property(copy, nonatomic, readwrite) id replacementClassMethodImplementation;

@end


@implementation Swizzlean

#pragma mark - Init Methods

- (id)initWithClassToSwizzle:(Class)swizzleClass
{
    self = [super init];
    if (self) {
        self.classToSwizzle = swizzleClass;
        self.isClassMethodSwizzled = NO;
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
    class_addMethod(klass, @selector(TEMP_CLASS_METHOD), replacementImp, TEMP_CLASS_METHOD_ENCODING);
    
    self.swizzleClassMethod = class_getClassMethod([Swizzlean class], @selector(TEMP_CLASS_METHOD_SEL));
    
    self.originalClassMethodImplementation = method_setImplementation(self.originalClassMethod, replacementImp);
    
    self.isClassMethodSwizzled = YES;
}

#pragma mark - Private Methods

- (void)createTempClassMethod
{
    Class klass = object_getClass(NSClassFromString(SWIZZLEAN_CLASS_NAME));
    IMP replacementImp = imp_implementationWithBlock(self.replacementClassMethodImplementation);
    class_addMethod(klass, @selector(TEMP_CLASS_METHOD), replacementImp, TEMP_CLASS_METHOD_ENCODING);
}

@end
