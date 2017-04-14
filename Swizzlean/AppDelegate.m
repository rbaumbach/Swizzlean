#import "AppDelegate.h"
#import "FirstViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) UIWindow *uiWindow;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.uiWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    FirstViewController *viewController = [[FirstViewController alloc] init];
    self.uiWindow.rootViewController = viewController;
    [self.uiWindow makeKeyAndVisible];
    return YES;
}

@end
