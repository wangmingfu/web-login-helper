//
//  Web_Login_HelperAppDelegate.m
//  Web Login Helper
//
//  Created by Mac on 2010/1/31.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Web_Login_HelperAppDelegate.h"
#import "RootViewController.h"


@implementation Web_Login_HelperAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

