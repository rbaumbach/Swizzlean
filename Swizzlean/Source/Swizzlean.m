//Copyright (c) 2013 Ryan Baumbach <rbaumbach.github@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining
//a copy of this software and associated documentation files (the "Software"),
//to deal in the Software without restriction, including
//without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to
//permit persons to whom the Software is furnished to do so, subject to
//the following conditions:
//
//The above copyright notice and this permission notice shall be
//included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


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
        self.resetWhenDeallocated = YES;
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
    
    if (!self.originalInstanceMethod) {
        NSString *methodName = NSStringFromSelector(originalMethod);
        NSString *reasonStr = [NSString stringWithFormat:@"Instance method doesn't exist: %@", methodName];
        @throw [NSException exceptionWithName:@"Swizzlean" reason:reasonStr userInfo:nil];
    }
    
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
    
    if (!self.originalClassMethod) {
        NSString *methodName = NSStringFromSelector(originalMethod);
        NSString *reasonStr = [NSString stringWithFormat:@"Class method doesn't exist: %@", methodName];
        @throw [NSException exceptionWithName:@"Swizzlean" reason:reasonStr userInfo:nil];
    }
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
        NSString *className = NSStringFromClass(self.classToSwizzle);
        NSString *reasonStr = [NSString stringWithFormat:@"Attempting to reset a swizzled instance method when one doesn't exist for class %@", className];
        @throw [NSException exceptionWithName:@"Swizzlean" reason:reasonStr userInfo:nil];
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
        NSString *className = NSStringFromClass(self.classToSwizzle);
        NSString *reasonStr = [NSString stringWithFormat:@"Attempting to reset a swizzled class method when one doesn't exist for class %@", className];
        @throw [NSException exceptionWithName:@"Swizzlean" reason:reasonStr userInfo:nil];
    }
    
    [self.runtimeUtils updateMethod:self.originalClassMethod
                  withImplemenation:self.originalClassMethodImplementation];
    
    self.originalClassMethod = nil;
    self.originalClassMethodImplementation = nil;
    self.replacementClassMethodImplementation = nil;
    self.currentClassMethodSwizzled = nil;
    self.isClassMethodSwizzled = NO;
}

- (void)dealloc
{
    if (!self.resetWhenDeallocated) {
        return;
    }
    
    if (self.isInstanceMethodSwizzled) {
        [self resetSwizzledInstanceMethod];
    }
    
    if (self.isClassMethodSwizzled) {
        [self resetSwizzledClassMethod];
    }
}

@end
