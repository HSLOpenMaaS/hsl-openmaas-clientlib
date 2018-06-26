#import "AppDelegate.h"
#import <CodePush/CodePush.h>

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;

  jsCodeLocation = [CodePush bundleURL];
  
  NSString *appVersion = @"1.2.0";
  [CodePush overrideAppVersion:(NSString *)appVersion];
  
  NSDictionary *initialProps = @{
     @"organizationId" : @"<YOU WILL GET THIS FROM HSL OPEN MAAS DEVELOPER PORTAL AFTER REGISTERING>",
     @"clientId" : @"<THIS IS THE SAME CLIENT ID YOU USE TO ORDER TICKETS>",
     @"dev" : @"YES",
   };
  
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"clientlib"
                                               initialProperties:initialProps
                                                   launchOptions:launchOptions];
  
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
