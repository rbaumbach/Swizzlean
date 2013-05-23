#import "Swizzlean.h"


#define SWIZZLEAN_CLASS_NAME        @"Swizzlean"

#define TEMP_CLASS_METHOD_SEL       tempClassMethod:
#define TEMP_CLASS_METHOD_ENCODING  "@@:"

@interface Swizzlean ()

@property(nonatomic, readwrite) Class classToSwizzle;
@property(nonatomic, readwrite) Method originalMethod;
@property(nonatomic, readwrite) Method swizzleMethod;
@property(copy, nonatomic, readwrite) id replacementImplementation;

@end


@implementation Swizzlean

#pragma mark - Init Methods

- (id)initWithClassToSwizzle:(Class)swizzleClass
{
    self = [super init];
    if (self) {
        self.classToSwizzle = swizzleClass;
    }
    return self;
}

#pragma mark - Public Methods

- (void)swizzleClassMethod:(SEL)originalMethod withReplacementImplementation:(id)replacementImplementation
{
    self.originalMethod = class_getClassMethod(self.classToSwizzle, originalMethod);
    self.replacementImplementation = replacementImplementation;
    
    [self createTempClassMethod];
    
    self.swizzleMethod = class_getClassMethod([Swizzlean class], @selector(TEMP_CLASS_METHOD_SEL));
}

#pragma mark - Private Methods

- (void)createTempClassMethod
{
    Class klass = object_getClass(NSClassFromString(SWIZZLEAN_CLASS_NAME));
    IMP replacementImp = imp_implementationWithBlock(self.replacementImplementation);
    class_addMethod(klass, @selector(TEMP_CLASS_METHOD), replacementImp, TEMP_CLASS_METHOD_ENCODING);
}

@end
