//
//  WebViewController.h
//  WebViewTutorial
//
//  Created by iPhone SDK Articles on 8/19/08.
//  Copyright 2008 www.iPhoneSDKArticles.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate> {
	
	IBOutlet UIWebView *webView;
	UIBarButtonItem *refBtn;
	
	NSString *ssid;
	NSString *pass;
	NSString *posturl;
	NSString *poststr;
	int rec_flag;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *ssid;
@property (nonatomic, retain) NSString *pass;
@property (nonatomic, retain) NSString *posturl;
@property (nonatomic, retain) NSString *poststr;

- (void) record_clicked:(id)sender;

- (void)setSSIDSTR:(NSString *)aStr;
- (void)setPASSSTR:(NSString *)aPass;

@end

