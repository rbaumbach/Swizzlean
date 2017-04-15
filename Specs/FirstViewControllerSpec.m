#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#import "FirstViewController.h"
#import "Swizzlean.h"

@interface FirstViewController ()

@property(strong, nonatomic) Swizzlean *swizzlean;

@end

SpecBegin(FirstViewControllerSpec)

describe(@"FirstViewController", ^{
    __block FirstViewController *controller;
    __block UIWindow *window;
    
    beforeEach(^{
        controller = [[FirstViewController alloc] init];
        window = [[UIWindow alloc] init];
        window.rootViewController = controller;
    });
    
    it(@"has an instance of swizzlean", ^{
        expect(controller.swizzlean).toNot.beNil();
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
            
            [swizzForViewDidLoad resetSwizzledInstanceMethod];
        });
        
        it(@"calls super, thanks for asking!", ^{
            expect(superViewDidLoadCalled).to.beTruthy();
        });
        
        describe(@"UI Controls", ^{
            context(@"name label", ^{
                it(@"middle aligns text", ^{
                    expect(controller.nameLabel.textAlignment).to.equal(NSTextAlignmentCenter);
                });
                
                it(@"has correct label text", ^{
                    expect(controller.nameLabel.text).to.equal(@"Swizzlean Test View");
                });
            });
            
            context(@"class label", ^{
                it(@"middle aligns text", ^{
                    expect(controller.classLabel.textAlignment).to.equal(NSTextAlignmentCenter);
                });
                
                it(@"has correct label text", ^{
                    expect(controller.classLabel.text).to.equal(@"Class: NSString");
                });
            });
            
            describe(@"Instance method display labels", ^{
                context(@"instance method label", ^{
                    it(@"left aligns text", ^{
                        expect(controller.instanceMethodLabel.textAlignment).to.equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        expect(controller.instanceMethodLabel.text).to.equal(@"Calling - [NSString intValue]");
                    });
                });
                
                context(@"instance output label", ^{
                    it(@"left aligns text", ^{
                        expect(controller.instanceOutputLabel.textAlignment).to.equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        expect(controller.instanceOutputLabel.text).to.equal(@"Output...");
                    });
                });
                
                context(@"instance method called output label", ^{
                    it(@"middle aligns text", ^{
                        expect(controller.instanceMethodCalledOutputLabel.textAlignment).to.equal(NSTextAlignmentCenter);
                    });
                    
                    it(@"has correct label text", ^{
                        NSString *expectedOutput = [NSString stringWithFormat:@"@\"777\" = %d", [@"777" intValue]];
                        expect(controller.instanceMethodCalledOutputLabel.text).to.equal(expectedOutput);
                    });
                });
                
                context(@"instance swizzled output label", ^{
                    it(@"left aligns text", ^{
                        expect(controller.instanceSwizzledOutputLabel.textAlignment).to.equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        expect(controller.instanceSwizzledOutputLabel.text).to.equal(@"Output After Swizzling...");
                    });
                });
                
                context(@"instance swizzled called output label", ^{
                    it(@"middle aligns text", ^{
                        expect(controller.instanceMethodCalledOutputLabel.textAlignment).to.equal(NSTextAlignmentCenter);
                    });
                    
                    it(@"has correct label text", ^{
                        expect(controller.instanceSwizzledCalledOutputLabel.text).to.equal(@"@\"777\" = 42");
                    });
                });
            });
            
            describe(@"Class method display labels", ^{
                context(@"class method label", ^{
                    it(@"middle aligns text", ^{
                        expect(controller.classMethodLabel.textAlignment).to.equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        expect(controller.classMethodLabel.text).to.equal(@"Calling + [NSString pathWithComponents:]");
                    });
                });
                
                context(@"class output label", ^{
                    it(@"middle aligns text", ^{
                        expect(controller.classOutputLabel.textAlignment).to.equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        expect(controller.classOutputLabel.text).to.equal(@"Output...");
                    });
                });
                
                context(@"class method called output label", ^{
                    it(@"middle aligns text", ^{
                        expect(controller.classMethodCalledOutputLabel.textAlignment).to.equal(NSTextAlignmentCenter);
                    });
                    
                    it(@"has correct label text", ^{
                        NSArray *pathArray = @[@"40", @"oz", @"beer", @"un-swizzled"];
                        NSString *pathComponent = [NSString pathWithComponents:pathArray];
                        expect(controller.classMethodCalledOutputLabel.text).to.equal(pathComponent);
                    });
                });
                
                context(@"class swizzled output label", ^{
                    it(@"left aligns text", ^{
                        expect(controller.classSwizzledOutputLabel.textAlignment).to.equal(NSTextAlignmentLeft);
                    });
                    
                    it(@"has correct label text", ^{
                        expect(controller.classSwizzledOutputLabel.text).to.equal(@"Output After Swizzling...");
                    });
                });
                
                context(@"class swizzled called output label", ^{
                    it(@"middle aligns text", ^{
                        expect(controller.classSwizzledCalledOutputLabel.textAlignment).to.equal(NSTextAlignmentCenter);
                    });
                    
                    it(@"has correct label text", ^{
                        NSString *replacedPath = @"24/oz/tallcan/beer/swizzled";
                        expect(controller.classSwizzledCalledOutputLabel.text).to.equal(replacedPath);
                    });
                });
            });
        });
    });
});

SpecEnd
