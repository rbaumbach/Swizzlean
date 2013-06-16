#import "FirstViewController.h"
#import "Swizzlean.h"


@interface FirstViewController ()

@property(strong, nonatomic) Swizzlean *swizzlean;

@end

@implementation FirstViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.swizzlean = [[Swizzlean alloc] initWithClassToSwizzle:[NSString class]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.classLabel.text = [NSString stringWithFormat:@"Class: %@", self.swizzlean.classToSwizzle];

    [self instanceMethodTestingUI];
    
    self.classMethodLabel.text = @"Calling + [NSString pathWithComponents:]";
}

- (void)instanceMethodTestingUI
{
    self.instanceMethodLabel.text = @"Calling - [NSString intValue]";
    
    NSString *sevenHundredSeventySeven = @"777";
    self.instanceMethodCalledOutputLabel.text = [NSString stringWithFormat:@"@\"777\" = %d", [sevenHundredSeventySeven intValue]];
    
    [self.swizzlean swizzleInstanceMethod:@selector(intValue)
            withReplacementImplementation:^ (id _self) {
                return 42;
            }];
    
    self.instanceSwizzledCalledOutputLabel.text = [NSString stringWithFormat:@"@\"777\" = %d", [sevenHundredSeventySeven intValue]];
    
    [self.swizzlean resetSwizzledInstanceMethod];
    
    NSArray *pathArray = @[@"40", @"oz", @"beer", @"un-swizzled"];
    self.classMethodCalledOutputLabel.text = [NSString pathWithComponents:pathArray];
    
    [self.swizzlean swizzleClassMethod:@selector(pathWithComponents:)
         withReplacementImplementation:^(id _self, NSString *input) {
             return @"24/oz/tallcan/beer/swizzled";
         }];
    
    self.classSwizzledCalledOutputLabel.text = [NSString pathWithComponents:@[]];
    
    [self.swizzlean resetSwizzledClassMethod];
}

@end
