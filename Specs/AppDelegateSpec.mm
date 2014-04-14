#import "AppDelegate.h"
#import "FirstViewController.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface AppDelegate ()

@property (strong, nonatomic, readonly) UIWindow *uiWindow;

@end

SPEC_BEGIN(AppDelegateSpec)

describe(@"AppDelegate", ^{
    __block AppDelegate *appDelegate;
    
    beforeEach(^{
        appDelegate = [[AppDelegate alloc] init];
    });
    
    it(@"conforms to <UIApplicationDelegate>", ^{
        [appDelegate conformsToProtocol:@protocol(UIApplicationDelegate)] should be_truthy;
    });
    
    describe(@"#application:didFinishLaunchingWithOptions:", ^{
        __block BOOL retAppDelegate;
        
        beforeEach(^{
            retAppDelegate = [appDelegate application:nil didFinishLaunchingWithOptions:nil];
        });
        
        context(@"ui window", ^{
            it(@"is not nil", ^{
                appDelegate.uiWindow should_not be_nil;
            });
            
            it(@"has a root view controller ", ^{
                appDelegate.uiWindow.rootViewController should be_instance_of([FirstViewController class]);
            });
            
            it(@"is displayed", ^{
                [appDelegate.uiWindow isKeyWindow] should be_truthy;
            });
        });
        
        it(@"returns YES", ^{
            retAppDelegate should be_truthy;
        });
    });
});

SPEC_END