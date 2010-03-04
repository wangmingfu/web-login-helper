//
//  TextViewController.m
//  wireless
//
//  Created by Mac on 2009/9/20.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TextViewController.h"
#import "InfoViewController.h"
#import "ASIHTTPRequest.h"

@implementation TextViewController

@synthesize textView, toolBar;
@synthesize weppass, ssid, posturl;

- (void)dealloc
{
	[infoNavController release];
	[ivControllerToolbar release];
	[ivControllerCell release];
	[toolBar release];
	[textView release];
	[super dealloc];
}

- (void) setupWifiParameters: (NSString* ) ssidtag: (NSString* ) pass
{
	self.ssid = ssidtag;
	NSLog(@"Received SSID: %@", self.ssid);
	self.weppass = pass;
	NSLog(@"Received WEPPASS: %@", self.weppass);
}

- (void)setupTextView: (NSString* ) text
{
	self.textView = [[[UITextView alloc] initWithFrame:self.view.frame] autorelease];
	self.textView.textColor = [UIColor blackColor];
	self.textView.font = [UIFont fontWithName:@"Arial" size:18];
	self.textView.delegate = self;
	self.textView.backgroundColor = [UIColor whiteColor];
	
	self.textView.text = text;
	self.textView.editable = NO;
	self.textView.returnKeyType = UIReturnKeyDefault;
	self.textView.keyboardType = UIKeyboardTypeDefault;	
	// use the default type input method (entire keyboard)
	self.textView.scrollEnabled = YES;
	
	// this will cause automatic vertical resize when the table is resized
	self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	// note: for UITextView, if you don't like autocompletion while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
	[self.view addSubview: self.textView];
	
	// TabBar
	self.toolBar = [UIToolbar new];
	self.toolBar.barStyle = UIBarStyleDefault;
	
	// size up the toolbar and set its frame
	[self.toolBar sizeToFit];
	CGFloat toolbarHeight = [self.toolBar frame].size.height;
	CGRect mainViewBounds = self.view.bounds;
	[self.toolBar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
								 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 2.0) + 2.0,
								 CGRectGetWidth(mainViewBounds),
								 toolbarHeight)];
	
	[self.view addSubview:self.toolBar];
	
	[self viewDidLoad];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Set title
	self.title = NSLocalizedString(@"URL HTML Resource", @"");
	
	// Set Functional Buttons
	UIBarButtonItem *ConfigButton = [[UIBarButtonItem alloc] 
									 initWithTitle:@"Setup" style:UIBarButtonItemStyleBordered 
									 target:self action:@selector(config_clicked:)];
	
	UIBarButtonItem *RefreshBtn = [[UIBarButtonItem alloc] 
									 initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered 
									 target:self action:@selector(refresh_clicked:)];
	
	[self.toolBar setItems:[NSArray arrayWithObjects:ConfigButton, RefreshBtn, nil]];
	
}

- (void) refresh_clicked:(id)sender {
	NSLog(@"Refresh_Clicked");
	
	// create the request
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		receivedData=[[NSMutableData data] retain];
	} else {
		// inform the user that the download could not be made
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"URL: %@", [[response URL]absoluteString]);
	self.posturl = [[response URL]absoluteString];
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	NSString* aStr = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	NSLog(@"receivedData = %@", aStr);
	
	
	textView.text = aStr;
	
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}

- (void) config_clicked:(id)sender {
	NSLog(@"Config_Click");
	
	//Initialize the Info View Controller
	if(ivControllerToolbar == nil)
		ivControllerToolbar = [[InfoViewController alloc] initWithNibName:@"TextFieldController" 
																   bundle:[NSBundle mainBundle]];
	
	ivControllerToolbar.isViewPushed = NO;
	[ivControllerToolbar setupWifiParameters: self.ssid: self.weppass: self.posturl];
	
	//Initialize the navigation controller with the info view controller
	if(infoNavController == nil)
		infoNavController = [[UINavigationController alloc] initWithRootViewController:ivControllerToolbar];
	
	//Present the navigation controller.
	[self.navigationController presentModalViewController:infoNavController animated:YES];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[self.textView release];
	[self.toolBar release];
	
	self.textView = nil;
	self.toolBar = nil;

}

- (void)viewWillAppear:(BOOL)animated 
{
    // listen for keyboard hide/show notifications so we can properly adjust the table's height
	[super viewWillAppear:animated];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end

@implementation NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end