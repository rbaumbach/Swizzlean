#import "Swizzlean.h"


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
    
    IMP replacementImp = imp_implementationWithBlock(self.replacementImplementation);
    Class klass = object_getClass(NSClassFromString(@"Swizzlean"));
    class_addMethod(klass, @selector(tempClassMethod), replacementImp, "@@:");
    
    self.swizzleMethod = class_getClassMethod([Swizzlean class], @selector(tempClassMethod));
}

@end
