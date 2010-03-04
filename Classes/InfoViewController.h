//
//  InfoViewController.h
//  UINavigationControllerWithToolbar
//
//  Created by iPhone SDK Articles on 9/16/08.
//  Copyright www.iPhoneSDKArticles.com 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WifiDataBase;

@interface InfoViewController : UITableViewController  <UITextFieldDelegate>
{
	BOOL isViewPushed;
	UITextField		*textFieldURL;
	UITextField		*textFieldPostStr;
	UITextField		*textFieldUser;
	UITextField		*textFieldPasswd;
	NSArray			*dataSourceArray;
	
	NSString *weppass;
	NSString *ssid;
	
	WifiDataBase *Db;
}

@property (nonatomic, readwrite) BOOL isViewPushed;
@property (nonatomic, retain, readonly) UITextField	*textFieldURL;
@property (nonatomic, retain, readonly) UITextField	*textFieldPostStr;
@property (nonatomic, retain, readonly) UITextField	*textFieldUser;
@property (nonatomic, retain, readonly) UITextField	*textFieldPasswd;

@property (nonatomic, retain) NSString *weppass;
@property (nonatomic, retain) NSString *ssid;

@property (nonatomic, retain) NSArray *dataSourceArray;

- (void) ShowInfoDialog: (NSString*)Title: (NSString*)Message;
- (void) setupWifiParameters: (NSString* ) ssidtag: (NSString* ) pass: (NSString*) url;

@end
