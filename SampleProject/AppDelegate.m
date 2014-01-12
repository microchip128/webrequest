#import "AppDelegate.h"
#import "RSSFeedController.h"
#import "SMWebRequest.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {

    // Demonstrate how we can listen globally to web request error events, to implement a systemwide failure message. Apple likes those!
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webRequestError:) name:kSMWebRequestError object:nil];
    
	// Example 1: Make an autoreleased "set it and forget it" web request to Google.
    SMWebRequest *request = [SMWebRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [request addTarget:self action:@selector(googleFinished:) forRequestEvents:SMWebRequestEventComplete];
    [request start];
    
    // Example 2: Make a simple but extremely nice+performant RSS reader for Hacker News! Courtesy @bvanderveen
    
    NSURL *url = [NSURL URLWithString:@"http://news.ycombinator.com/rss"]; // you can really use any RSS url here
    RSSFeedController *home = [[RSSFeedController alloc] initWithRSSFeedURL:url];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.toolbarHidden = NO;
    
    // Mimic the HN site.
    home.title = @"Hacker News";
    home.tableView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:239.0/255.0 alpha:1];
    nav.navigationBar.barTintColor = [UIColor colorWithRed:235.0/255.0 green:120.0/255.0 blue:31.0/255.0 alpha:1];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

// Callback from Example 1: we simply get an NSData with the server response.
- (void)googleFinished:(NSData *)responseData {
    NSLog(@"Got a response of %i bytes.", responseData.length);
}

// Global error handler displays a simple failure message.
- (void)webRequestError:(NSNotification *)notification {
    static bool displayedOfflineAlert = NO;
    static NSString *title = @"Request Error";
    static NSString *message = @"You appear to be offline. Please try again later.";
    
    if (!displayedOfflineAlert) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        displayedOfflineAlert = YES;
    }
}

@end
