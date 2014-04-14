#import "FirstViewController.h"
#import "Swizzlean.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface FirstViewController ()

@property(strong, nonatomic) Swizzlean *swizzlean;

@end

SPEC_BEGIN(FirstViewControllerSpec)

describe(@"FirstViewController", ^{
    __block FirstViewController *controller;
    __block UIWindow *window;
    
    beforeEach(^{
        controller = [[FirstViewController alloc] init];
        window = [[UIWindow alloc] init];
        window.rootViewController = controller;
    });
    
    it(@"has an instance of swizzlean", ^{
        controller.swizzlean should_not be_nil;
    });
    
    describe(@"#ViewDidLoad", ^{
        __block Swizzlean *swizzForViewDidLoad;
        __block BOOL superViewDidLoadCalled;
        
        beforeEach(^{
            superViewDidLoadCalled = NO;
            swizzForViewDidLoad = [[Swizzlean alloc] initWithClassToSwizzle:[UIViewController class]];
            [swizzForViewDidLoad swizzleInstanceMethod:@selector(viewDidLoad)
                         withReplacementImplementation:^(id _self){
                             superViewDidLoadCalled = YES;
                         }];
            
            [window makeKeyAndVisible];
            [controller viewDidLoad];
            
            [swizzForViewDidLoad resetSwizzledClassMethod];
        });
        
        it(@"calls super, thanks for asking!", ^{
            superViewDidLoadCalled should be_truthy;
        });
        
        describe(@"UI Controls", ^{
            context(@"name label", ^{
                it(@"is placed in the correct location", ^{
                    controller.nameLabel.frame.origin.x should equal(20);
                    controller.nameLabel.frame.origin.y should equal(20);
                });
                
                it(@"is the correct size", ^{
                    controller.nameLabel.frame.size.width should equal(280);
                    controller.nameLabel.frame.size.height should equal(21);
                });
                
                it(@"middle aligns text", ^{
                    controller.nameLabel.textAlignment should equal(NSTextAlignmentCenter);
                });
                
                it(@"has correct label text", ^{
                    controller.nameLabel.text should equal(@"Swizzlean Test View");
                });
            });
            
            context(@"class label", ^{
                it(@"is placed in the correct location", ^{
                    controller.classLabel.frame.origin.x should equal(20);
                    controller.classLabel.frame.origin.y should equal(49);
                });
                
                it(@"is the correct size", ^{
                    controller.nameLabel.frame.size.width should equal(280);
                    controller.nameLabel.frame.size.height should equal(21);
                });
                
                it(@"middle aligns text", ^{
                    controller.classLabel.textAlignment should equal(NSTextAlignmentCenter);
                });
                
                it(@"has correct label text", ^{
                    controller.classLabel.text should equal(@"Class: NSString");
                });
            });
            
            describe(@"Instance method display labels", ^{
                context(@"instance method label", ^{
                    it(@"is placed in the correct location", ^{
                        controller.instanceMethodLabel.frame.origin.x should equal(20);
                        controller.instanceMethodLabel.frame.origin.y should equal(103);
                    });
                    
                    it(@"is the correct size", ^{
                        controller.instanceMethodLabel.frame.size.width should equal(280);
                        controller.instanceMethodLabel.frame.size.height should equal(21);
                    });
                    
                    it(@"middle aligns text", ^{
                        controller.instanceMethodLabel.textAlignment should equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        controller.instanceMethodLabel.text should equal(@"Calling - [NSString intValue]");
                    });
                });
                
                context(@"instance output label", ^{
                    it(@"is placed in the correct location", ^{
                        controller.instanceOutputLabel.frame.origin.x should equal(20);
                        controller.instanceOutputLabel.frame.origin.y should equal(132);
                    });
                    
                    it(@"is the correct size", ^{
                        controller.instanceOutputLabel.frame.size.width should equal(66);
                        controller.instanceOutputLabel.frame.size.height should equal(21);
                    });
                    
                    it(@"middle aligns text", ^{
                        controller.instanceOutputLabel.textAlignment should equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        controller.instanceOutputLabel.text should equal(@"Output...");
                    });
                });
                
                context(@"instance method called output label", ^{
                    it(@"is placed in the correct location", ^{
                        controller.instanceMethodCalledOutputLabel.frame.origin.x should equal(20);
                        controller.instanceMethodCalledOutputLabel.frame.origin.y should equal(161);
                    });
                    
                    it(@"is the correct size", ^{
                        controller.instanceMethodCalledOutputLabel.frame.size.width should equal(280);
                        controller.instanceMethodCalledOutputLabel.frame.size.height should equal(21);
                    });
                    
                    it(@"middle aligns text", ^{
                        controller.instanceMethodCalledOutputLabel.textAlignment should equal(NSTextAlignmentCenter);
                    });
                    
                    it(@"has correct label text", ^{
                        NSString *expectedOutput = [NSString stringWithFormat:@"@\"777\" = %d", [@"777" intValue]];
                        controller.instanceMethodCalledOutputLabel.text should equal(expectedOutput);
                    });
                });
                
                context(@"instance swizzled output label", ^{
                    it(@"is placed in the correct location", ^{
                        controller.instanceSwizzledOutputLabel.frame.origin.x should equal(20);
                        controller.instanceSwizzledOutputLabel.frame.origin.y should equal(190);
                    });
                    
                    it(@"is the correct size", ^{
                        controller.instanceSwizzledOutputLabel.frame.size.width should equal(182);
                        controller.instanceSwizzledOutputLabel.frame.size.height should equal(21);
                    });
                    
                    it(@"middle aligns text", ^{
                        controller.instanceSwizzledOutputLabel.textAlignment should equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        controller.instanceSwizzledOutputLabel.text should equal(@"Output After Swizzling...");
                    });
                });
                
                context(@"instance swizzled called output label", ^{
                    it(@"is placed in the correct location", ^{
                        controller.instanceSwizzledCalledOutputLabel.frame.origin.x should equal(20);
                        controller.instanceSwizzledCalledOutputLabel.frame.origin.y should equal(219);
                    });
                    
                    it(@"is the correct size", ^{
                        controller.instanceSwizzledCalledOutputLabel.frame.size.width should equal(280);
                        controller.instanceSwizzledCalledOutputLabel.frame.size.height should equal(21);
                    });
                    
                    it(@"middle aligns text", ^{
                        controller.instanceSwizzledCalledOutputLabel.textAlignment should equal(NSTextAlignmentCenter);
                    });
                    
                    it(@"has correct label text", ^{
                        controller.instanceSwizzledCalledOutputLabel.text should equal(@"@\"777\" = 42");
                    });
                });
            });
            
            describe(@"Class method display labels", ^{
                context(@"class method label", ^{
                    it(@"is placed in the correct location", ^{
                        controller.classMethodLabel.frame.origin.x should equal(20);
                        controller.classMethodLabel.frame.origin.y should equal(286);
                    });
                    
                    it(@"is the correct size", ^{
                        controller.classMethodLabel.frame.size.width should equal(280);
                        controller.classMethodLabel.frame.size.height should equal(21);
                    });
                    
                    it(@"middle aligns text", ^{
                        controller.classMethodLabel.textAlignment should equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        controller.classMethodLabel.text should equal(@"Calling + [NSString pathWithComponents:]");
                    });
                });
                
                context(@"class output label", ^{
                    it(@"is placed in the correct location", ^{
                        controller.classOutputLabel.frame.origin.x should equal(20);
                        controller.classOutputLabel.frame.origin.y should equal(315);
                    });
                    
                    it(@"is the correct size", ^{
                        controller.classOutputLabel.frame.size.width should equal(66);
                        controller.classOutputLabel.frame.size.height should equal(21);
                    });
                    
                    it(@"middle aligns text", ^{
                        controller.classOutputLabel.textAlignment should equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        controller.classOutputLabel.text should equal(@"Output...");
                    });
                });
                
                context(@"class method called output label", ^{
                    it(@"is placed in the correct location", ^{
                        controller.classMethodCalledOutputLabel.frame.origin.x should equal(20);
                        controller.classMethodCalledOutputLabel.frame.origin.y should equal(344);
                    });
                    
                    it(@"is the correct size", ^{
                        controller.classMethodCalledOutputLabel.frame.size.width should equal(280);
                        controller.classMethodCalledOutputLabel.frame.size.height should equal(21);
                    });
                    
                    it(@"middle aligns text", ^{
                        controller.classMethodCalledOutputLabel.textAlignment should equal(NSTextAlignmentCenter);
                    });
                    
                    it(@"has correct label text", ^{
                        NSArray *pathArray = @[@"40", @"oz", @"beer", @"un-swizzled"];
                        NSString *pathComponent = [NSString pathWithComponents:pathArray];
                        controller.classMethodCalledOutputLabel.text should equal(pathComponent);
                    });
                });
                
                context(@"class swizzled output label", ^{
                    it(@"is placed in the correct location", ^{
                        controller.classSwizzledOutputLabel.frame.origin.x should equal(20);
                        controller.classSwizzledOutputLabel.frame.origin.y should equal(373);
                    });
                    
                    it(@"is the correct size", ^{
                        controller.classSwizzledOutputLabel.frame.size.width should equal(182);
                        controller.classSwizzledOutputLabel.frame.size.height should equal(21);
                    });
                    
                    it(@"middle aligns text", ^{
                        controller.classSwizzledOutputLabel.textAlignment should equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        controller.classSwizzledOutputLabel.text should equal(@"Output After Swizzling...");
                    });
                });
                
                context(@"class swizzled called output label", ^{
                    it(@"is placed in the correct location", ^{
                        controller.classSwizzledCalledOutputLabel.frame.origin.x should equal(20);
                        controller.classSwizzledCalledOutputLabel.frame.origin.y should equal(402);
                    });
                    
                    it(@"is the correct size", ^{
                        controller.classSwizzledCalledOutputLabel.frame.size.width should equal(280);
                        controller.classSwizzledCalledOutputLabel.frame.size.height should equal(21);
                    });
                    
                    it(@"middle aligns text", ^{
                        controller.classSwizzledCalledOutputLabel.textAlignment should equal(NSTextAlignmentCenter);
                    });
                    
                    it(@"has correct label text", ^{
                        NSString *replacedPath = @"24/oz/tallcan/beer/swizzled";
                        controller.classSwizzledCalledOutputLabel.text should equal(replacedPath);
                    });
                });
            });
        });
    });
});

SPEC_END