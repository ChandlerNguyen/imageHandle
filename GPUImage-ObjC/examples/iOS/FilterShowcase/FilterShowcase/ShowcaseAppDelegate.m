#import "ShowcaseAppDelegate.h"
#import "ShowcaseFilterListController.h"
#import "OtherTableViewController.h"

@implementation ShowcaseAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    UITabBarController *mainTabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    
    /** 图片滤镜 */
    ShowcaseFilterListController *filterListController = [[ShowcaseFilterListController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *filterNav = [[UINavigationController alloc] initWithRootViewController:filterListController];
    UITabBarItem *filterItem = [[UITabBarItem alloc] initWithTitle:@"filterCase" image:[UIImage imageNamed:@"icon"] tag:0];
    filterNav.tabBarItem = filterItem;
    
    OtherTableViewController *other = [[OtherTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *otherNav = [[UINavigationController alloc] initWithRootViewController:other];
    UITabBarItem *otherItem = [[UITabBarItem alloc] initWithTitle:@"other" image:[UIImage imageNamed:@"icon"] tag:1];
    
    otherNav.tabBarItem = otherItem;
    
    mainTabBarController.viewControllers = @[filterNav,otherNav];
    mainTabBarController.selectedViewController = filterNav;
    
    [self.window setRootViewController:mainTabBarController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
