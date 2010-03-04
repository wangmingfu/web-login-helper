//
//  WebViewController.m
//  WebViewTutorial
//
//  Created by iPhone SDK Articles on 8/19/08.
//  Copyright 2008 www.iPhoneSDKArticles.com. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize webView;
@synthesize ssid, pass, posturl, poststr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

/*
 If you need to do additional setup after loading the view, override viewDidLoad. */
- (void)viewDidLoad {
	
	NSLog(@"Starting google url first!");
	// For testing
	NSString *urlAddress = @"http://www.google.com";
	//Create a URL object.
	NSURL *url = [NSURL URLWithString:urlAddress];
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	//Load the request in the UIWebView.
	[webView loadRequest:requestObj];
	
	rec_flag = 0;
	// add record button
	refBtn = [[UIBarButtonItem alloc] initWithTitle:@"Record" style:UIBarButtonItemStylePlain 
											  target:self action:@selector(record_clicked:)];
	self.navigationItem.rightBarButtonItem = refBtn;
	[refBtn release];
}

- (void) record_clicked:(id)sender {
	NSLog(@"Start Record");
	rec_flag = 1;
	[self.navigationItem.rightBarButtonItem setTitle: @"ACTION"];
	[self.navigationItem.rightBarButtonItem setEnabled: NO];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType 
{
	NSLog(@"shouldStartLoadWithRequest");
	[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost: [[request URL]host]];
	
	if(rec_flag==1){
		NSLog(@"Recording..");
		self.posturl = [[[self.webView request] URL] absoluteString];
		NSLog(@"posturl = %@", [[[self.webView request] URL] absoluteString]);
		
		NSLog(@"HTTPBody len= %d", [[[self.webView request] HTTPBody] length]);
		NSDictionary *dictionary = [[self.webView request] allHTTPHeaderFields];
		for (id key in dictionary) {
			NSLog(@"HTTPHeaderFields - key: %@, value: %@", key, [dictionary objectForKey:key]);
		}
	}
	/*
	if(navigationType == UIWebViewNavigationTypeLinkClicked) {
			//[self myMethodAction];
			[self.webView stopLoading];
			return YES;
	}
	*/
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

/*
- (void)setScanner:(MSNetworksManager *)aScanner
{
	scan = aScanner;
}
*/
- (void)setSSIDSTR:(NSString *)aStr
{
	self.ssid = aStr;
}

- (void)setPASSSTR:(NSString *)aStr
{
	self.pass = aStr;
}

- (void)dealloc {
	[webView release];
	[super dealloc];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	NSLog(@"webViewDidStartLoad");
	if(rec_flag==1){
		NSLog(@"Recording..");
		self.posturl = [[[self.webView request] URL] absoluteString];
		NSLog(@"posturl = %@", [[[self.webView request] URL] absoluteString]);
		NSString* encstring = [[NSString alloc] initWithData: 
							   [[self.webView request] HTTPBody] encoding: NSASCIIStringEncoding];
		NSLog(@"HTTPBody = %@", encstring);
		NSDictionary *dictionary = [[self.webView request] allHTTPHeaderFields];
		for (id key in dictionary) {
			NSLog(@"HTTPHeaderFields - key: %@, value: %@", key, [dictionary objectForKey:key]);
		}
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	NSLog(@"webViewDidFinishLoad");
	// self.posturl = [[[self.webView request] URL] absoluteString];
	if(rec_flag==1){
		NSLog(@"Recording..");
		self.posturl = [[[self.webView request] URL] absoluteString];
		NSLog(@"posturl = %@", [[[self.webView request] URL] absoluteString]);
		NSString* encstring = [[NSString alloc] initWithData: 
				[[self.webView request] HTTPBody] encoding: NSASCIIStringEncoding];
		NSLog(@"HTTPBody = %@", encstring);
		NSDictionary *dictionary = [[self.webView request] allHTTPHeaderFields];
		for (id key in dictionary) {
			NSLog(@"HTTPHeaderFields - key: %@, value: %@", key, [dictionary objectForKey:key]);
		}
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	NSLog(@"didFailLoadWithError");
	if(rec_flag==1){
		NSLog(@"Recording..");
	}
	// report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
							 error.localizedDescription];
	[self.webView loadHTMLString:errorString baseURL:nil];
}


@end

@implementation NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end
