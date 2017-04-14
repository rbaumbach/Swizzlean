#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

#import "AppDelegate.h"
#import "FirstViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic, readonly) UIWindow *uiWindow;

@end

SpecBegin(AppDelegateSpec)

describe(@"AppDelegate", ^{
    __block AppDelegate *appDelegate;
    
    beforeEach(^{
        appDelegate = [[AppDelegate alloc] init];
    });
    
    it(@"conforms to <UIApplicationDelegate>", ^{
        expect(appDelegate).to.conformTo(@protocol(UIApplicationDelegate));
    });
    
    describe(@"#application:didFinishLaunchingWithOptions:", ^{
        __block BOOL retAppDelegate;
        __block id fakeApplication;
        
        beforeEach(^{
            fakeApplication = OCMClassMock([UIApplication class]);
            retAppDelegate = [appDelegate application:fakeApplication didFinishLaunchingWithOptions:nil];
        });
        
        context(@"ui window", ^{
            it(@"is not nil", ^{
                expect(appDelegate.uiWindow).toNot.beNil();
            });
            
            it(@"has a root view controller ", ^{
                expect(appDelegate.uiWindow.rootViewController).to.beInstanceOf([FirstViewController class]);
            });
            
            it(@"is displayed", ^{
                expect(appDelegate.uiWindow.isKeyWindow).to.beTruthy();
            });
        });
        
        it(@"returns YES", ^{
            expect(retAppDelegate).to.beTruthy();
        });
    });
});

SpecEnd
