//
//  Web_Login_HelperAppDelegate.h
//  Web Login Helper
//
//  Created by Mac on 2010/1/31.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@interface Web_Login_HelperAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

