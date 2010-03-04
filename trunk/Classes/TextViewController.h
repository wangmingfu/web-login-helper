//
//  TextViewController.h
//  wireless
//
//  Created by Mac on 2009/9/20.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfoViewController;

@interface TextViewController : UIViewController <UITextViewDelegate, UINavigationBarDelegate, UITextFieldDelegate>
{
	UITextView	*textView;
	UIToolbar	*toolBar;
	
	InfoViewController *ivControllerToolbar;
	InfoViewController *ivControllerCell;
	UINavigationController *infoNavController;
	
	NSString *weppass;
	NSString *ssid;
	NSString *posturl;
	NSMutableData* receivedData;
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIToolbar	*toolBar;
@property (nonatomic, retain) NSString *weppass;
@property (nonatomic, retain) NSString *ssid;
@property (nonatomic, retain) NSString *posturl;

- (void) setupTextView: (NSString* ) text;
- (void) setupWifiParameters: (NSString* ) ssidtag: (NSString* ) pass;
- (void) config_clicked:(id)sender;

@end
