#import "FirstViewController.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FirstViewControllerSpec)

describe(@"FirstViewController", ^{
    __block FirstViewController *controller;
    __block UIWindow *window;
    
    beforeEach(^{
        controller = [[FirstViewController alloc] init];
        window = [[UIWindow alloc] init];
        window.rootViewController = controller;
    });
    
    describe(@"#ViewDidLoad", ^{
        beforeEach(^{
            [window makeKeyAndVisible];
        });
        
        describe(@"status label", ^{
            it(@"has a label", ^{
                controller.statusLabel should_not be_nil;
            });
            
            it(@"is placed in the correct location", ^{
                controller.statusLabel.frame.origin.x should equal(20);
                controller.statusLabel.frame.origin.y should equal(20);
            });
            
            it(@"middle aligns text", ^{
                controller.statusLabel.textAlignment should equal(NSTextAlignmentCenter);
            });
            
            it(@"has correct label text", ^{
                controller.statusLabel.text should equal(@"First View Controller");
            });
        });
    });
});

SPEC_END