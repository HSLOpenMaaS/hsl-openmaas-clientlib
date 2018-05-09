//
//  OwnTicketsViewController.m
//  example-app-ios
//

#import "OwnTicketsViewController.h"
#import <CodePush/CodePush.h>

#import <React/RCTRootView.h>

@interface OwnTicketsViewController ()

@end

@implementation OwnTicketsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *jsCodeLocation;
    jsCodeLocation = [CodePush bundleURL];
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"HSL Open MaaS Clientlib Version"];
    [CodePush overrideAppVersion:(NSString *)appVersion];
    
    NSDictionary *initialProps = @{
        @"organizationId" : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"HSL Open MaaS Organization Id"],
        @"clientId" : @"MaaSOperatorAssignedUniqueId",
        @"dev" : @"YES",
    };
    
    RCTRootView *rootView = [[RCTRootView alloc]
        initWithBundleURL:jsCodeLocation
        moduleName:@"clientlib"
        initialProperties:initialProps
        launchOptions:nil
    ];
    
    rootView.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.view addSubview:rootView];

    if (@available(iOS 11, *)) {
        UILayoutGuide * guide = self.view.safeAreaLayoutGuide;
        [rootView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
        [rootView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES;
        [rootView.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
        [rootView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    } else {
        UILayoutGuide *margins = self.view.layoutMarginsGuide;
        [rootView.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor].active = YES;
        [rootView.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor].active = YES;
        [rootView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
        [rootView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;
    }

    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
