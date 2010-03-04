//
//  DetailViewController.m
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "DetailViewController.h"
#import "Scanner.h"
#import "ASIHTTPRequest.h"
#import "WifiDataBase.h"
#import "Utility.h"
#import "TextViewController.h"
#import "WebViewController.h"

#define MAX_ROUND 100000

@implementation DetailViewController

@synthesize tableView, wificonfig, ssid, weppass;

// The designated initializer. Override to perform setup that is required before the view is loaded.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	}
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	//Allocate Utility Object
	util = [[Utility init]alloc];
	
	// Add associate button
	associateBtn = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStylePlain 
											  target:self action:@selector(toggleAssociate:)];
	
	profileBtn = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain 
												 target:self action:@selector(toggleNewProfile:)];
	
	delBtn = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain 
												target:self action:@selector(toggleDelProfile:)];
	
	Db = [[WifiDataBase alloc]init];
	
	//Set the title of the navigation bar
	self.navigationItem.title = @"Selected AP";
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)toggleNewProfile:(id)sender
{
	if([[selectedNetwork objectForKey:@"WEP"] boolValue]||
		([selectedNetwork objectForKey:@"WPA_IE"])||
		([selectedNetwork objectForKey:@"RSN_IE"]))
			[self showPassDialog];
	else {
		int ret = [Scanner associateNetwork: selectedNetwork: nil];
		NSLog(@"associateNetwork code: %d", ret);
		// Start Create a new profile.
		errorcnt = 0;
		while([util localIPAddress]==@"error")
		{
			errorcnt++;
			if(errorcnt > MAX_ROUND)
				break;
		}
		if([util localIPAddress]==@"error") {
			NSLog(@"Timeout or passwords error");
			[self ShowErrorWarning: @"Error": @"TimeOut Or Password Error!"];
		}else {
			[self ShowErrorWarning: @"IP Notification" :[util localIPAddress]];
			[self CreateNewProfile];
		}
	}	
}

- (void)toggleDelProfile:(id)sender
{
	NSLog(@"Plan to del SSID: %@", self.ssid);
	
	configDialog = [[UIAlertView alloc] init];
	[configDialog setTitle:@"Delete Configuration"];
	[configDialog setMessage:@"Confirm to Delete"];
	[configDialog setDelegate:self];
	[configDialog addButtonWithTitle:@"Cancel"];
	[configDialog addButtonWithTitle:@"Del"];
	
	//CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
	//[configDialog setTransform:myTransform];		
	[configDialog show];
	[configDialog release];	
	
}

- (void) ShowErrorWarning: (NSString*)Title: (NSString*)Message
{
	UIAlertView *Alert = [[UIAlertView alloc]
						  initWithTitle:Title
						  message:Message
						  delegate:nil
						  cancelButtonTitle:@"Done"
						  otherButtonTitles:nil];
	
	[Alert show];
	[Alert autorelease];
}

- (void) CreateNewProfile
{
	// not yet implemented
	NSString* response = [self testConnection: @"http://www.google.com.tw/intl/zh-TW/about.html"];
	NSLog(@"res: %@", response);
	NSString *searchForMe = @"Google";
	NSRange range =  [response rangeOfString : searchForMe];
	
	if ((response!=nil)&&(range.location != NSNotFound)) 
	{
		NSLog(@"I found google in html code.");
		// No need to view html code
		if(Db!=nil) {
			if(self.weppass==nil) {
				NSLog(@"open");
				[Db addEntryToDatabase: self.ssid: @"Null": @"Null": @"Null": @"Null": @"Null" : @"0"];	
			}else {
				NSLog(@"weppass");
				[Db addEntryToDatabase: self.ssid: self.weppass: @"Null": @"Null": @"Null": @"Null" : @"1"];
			}
			[self ShowErrorWarning: @"Info": @"Configuration Save"];
		}
	}else {
		[self CreateNewFrame: response];
	}
	
	
	
	/*
	WebViewController *NewPage = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:NewPage animated:YES];
	
	NSLog(@"ssid: %@", self.ssid);
	NSLog(@"weppass: %@", self.weppass);
	
	[NewPage setSSIDSTR: self.ssid ];
	[NewPage setPass: self.weppass ];
	
	[NewPage release];
	NewPage = nil;
	*/
}

- (void) CreateNewFrame: (NSString*) Text
{
	//Initialize the detail view controller and display it.
	TextViewController *NewPage = [[TextViewController alloc] 
								   initWithNibName:@"TextViewController" bundle:[NSBundle mainBundle]];
	[NewPage setupTextView: Text];
	NSLog(@"ssid: %@", self.ssid);
	NSLog(@"weppass: %@", self.weppass);
	[NewPage setupWifiParameters:self.ssid : self.weppass];
	
	// dvController.selectedAP = selectedAP;
	[self.navigationController pushViewController:NewPage animated:YES];
	[NewPage release];
	NewPage = nil;
}

- (NSString*) testConnection: (NSString*)URLStr
{
	NSURL *url = [NSURL URLWithString: URLStr];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	[request start];
	NSError *error = [request error];
	int rescode = [request responseStatusCode];
	NSLog(@"status code = %d", rescode);
	NSDictionary *map = [request responseHeaders];
	
	NSEnumerator *enumerator = [map keyEnumerator];
    for(NSString *aKey in enumerator){
        NSLog(@"key(%@) = %@", aKey, [map valueForKey:aKey]);
    }
	
	if (!error) {
		NSString *response = [request responseString];
		NSLog(response);
		return response;
	}else
		return nil;
}

// Customize the number of rows in the table view.

- (void)dealloc {
	[Db dealloc];
	[configDialog dealloc];
	[weptext dealloc];
	[InfoArray dealloc];
	[util dealloc];
	[super dealloc];
}

// for table tableView
- (void)loadView
{
	InfoArray = [[NSMutableArray alloc]init];
	[InfoArray addObject: @"SSID_STR"];
	[InfoArray addObject: @"WEP"];
	[InfoArray addObject: @"RSSI"];
	[InfoArray addObject: @"AP_MODE"];
	[InfoArray addObject: @"SSID"];
	[InfoArray addObject: @"CHANNEL"];
	[InfoArray addObject: @"BSSID"];
	[InfoArray addObject: @"AGE"];
	[InfoArray addObject: @"NOISE"];
	
    tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                             style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
	
    self.view = tableView;
    [tableView release];
}

- (void)setScanner:(MSNetworksManager *)aScanner 
{
	Scanner = aScanner;
}

/*
- (void)setDBObject:(WifiDataBase *)aDB
{
	Db = aDB;
}
*/

- (void)toggleAssociate:(id)sender
{
	NSLog(@"toggleAssociate");
	
	// for debug
	NSLog(@"SSID: %@", [self.wificonfig objectAtIndex:0]);
	NSLog(@"WEPPASS: %@", [self.wificonfig objectAtIndex:1]);
	NSLog(@"URL: %@", [self.wificonfig objectAtIndex:2]);
	NSLog(@"POSTSTR: %@", [self.wificonfig objectAtIndex:3]);
	NSLog(@"USER: %@", [self.wificonfig objectAtIndex:4]);
	NSLog(@"PASS: %@", [self.wificonfig objectAtIndex:5]);
	
	NSString *tmp = (NSString*)[self.wificonfig objectAtIndex:6];
	int auth = [tmp intValue];
	NSLog(@"AUTH: %d", auth);
	
	switch(auth) 
	{
		case 0:
			NSLog(@"case 0");
			// No weppass, No url authentication
			if(Scanner!=nil) {
				[Scanner associateNetwork: selectedNetwork: nil];
				while([Scanner localIPAddress]==@"error");
				NSLog(@"IP Address = %@", [Scanner localIPAddress]);
				[self ShowErrorWarning: @"Message": @"Connect to the WiFi network"];
			}
			break;
		case 1:
			NSLog(@"case 1");
			// wep security, No url authentication
			if(Scanner!=nil) {
				NSLog(@"PASS:%@", [self.wificonfig objectAtIndex:1]);
				[Scanner associateNetwork: selectedNetwork: [self.wificonfig objectAtIndex:1]];
				while([Scanner localIPAddress]==@"error");
				NSLog(@"IP Address = %@", [Scanner localIPAddress]);
				[self ShowErrorWarning: @"Message": @"Connect to the WiFi network"];
			}
			break;
		case 2:
			NSLog(@"case 2");
			// No weppass, url authentication
			if(Scanner!=nil) {
				[Scanner associateNetwork: selectedNetwork: nil];
				while([Scanner localIPAddress]==@"error");
				NSLog(@"IP Address = %@", [Scanner localIPAddress]);
				NSString *targeturl = (NSString*)[self.wificonfig objectAtIndex:2];
				NSString *postStr = (NSString*)[self.wificonfig objectAtIndex:3];
				NSString *user = (NSString*)[self.wificonfig objectAtIndex:4];
				NSString *pass = (NSString*)[self.wificonfig objectAtIndex:5];
				postStr = [util replacePostdata: postStr: user: pass];
				NSLog(postStr);
				[self SendAuthPost: targeturl : targeturl];
				
			}
			break;
		case 3:
			NSLog(@"case 3");
			// wep security, url authentication
			if(Scanner!=nil) {
				[Scanner associateNetwork: selectedNetwork: [self.wificonfig objectAtIndex:1]];
				while([Scanner localIPAddress]==@"error");
				NSLog(@"IP Address = %@", [Scanner localIPAddress]);
				NSString *targeturl = (NSString*)[self.wificonfig objectAtIndex:2];
				NSString *postStr = (NSString*)[self.wificonfig objectAtIndex:3];
				NSString *user = (NSString*)[self.wificonfig objectAtIndex:4];
				NSString *pass = (NSString*)[self.wificonfig objectAtIndex:5];
				postStr = [util replacePostdata: postStr: user: pass];
				NSLog(postStr);
				[self SendAuthPost: targeturl : targeturl];
				
			}
			break;
		default:
			NSLog(@"unknown, error type");
			// unknown type
			break;
	}
	
}

- (void) showPassDialog
{
	
	configDialog = [[UIAlertView alloc] init];
	[configDialog setTitle:@"Enter Password:"];
	[configDialog setMessage:@"Password"];
	[configDialog setDelegate:self];
	[configDialog addButtonWithTitle:@"Cancel"];
	[configDialog addButtonWithTitle:@"OK"];
	// [configDialog addButtonWithTitle:@"Button #2"];
	weptext = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
	
	[weptext setBackgroundColor:[UIColor whiteColor]];
	weptext.secureTextEntry = YES;
	weptext.text = @"";
	[configDialog addSubview:weptext];
	
	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
	[configDialog setTransform:myTransform];		
	[configDialog show];
	[weptext becomeFirstResponder];
	[configDialog release];	
	[weptext release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	
	if((actionSheet.title==@"Enter Password:")&&(buttonIndex == 1)) 
	{
		NSLog(@"weptext: %@", weptext.text );
		[Scanner associateNetwork: selectedNetwork: weptext.text];
		self.weppass = weptext.text;
		// Start Create a new profile.
		errorcnt = 0;
		while([util localIPAddress]==@"error")
		{
			errorcnt++;
			if(errorcnt > MAX_ROUND)
				break;
		}
		if([util localIPAddress]==@"error") {
			NSLog(@"Timeout or passwords error");
			[self ShowErrorWarning: @"Error": @"TimeOut Or Password Error!"];
		}else {
			[self ShowErrorWarning: @"IP Notification" :[util localIPAddress]];
			[self CreateNewProfile];
		}
	}
	
	if((actionSheet.title==@"Delete Configuration")&&(buttonIndex == 1)) 
	{
		if(Db!=nil) {
			NSLog(@"Ready to Del SSID: %@", self.ssid );
			[Db delEntryToDatabase:self.ssid];
			exit(0);
		}
	}
	
}

- (void)SendAuthPost: (NSString*)URLStr: (NSString*)postData 
{
	NSURL *url = [NSURL URLWithString: URLStr];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	// Accept All InValid or valid Certificates
	[request setValidatesSecureCertificate:NO];
	
	[request appendPostData:[postData dataUsingEncoding:NSASCIIStringEncoding]];
	// Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
	[request setRequestMethod:@"POST"];
	[request start];
	
	NSError *error = [request error];
	int statusCode = [request responseStatusCode];
	NSLog(@"statusCode = %d", statusCode);
	
	if (!error) {
		NSString *response = [request responseString]; 
		NSLog(response);
		[self ShowErrorWarning: @"Message": @"Connect to the WiFi network"];
	} else {
		// inform the user
		NSLog(@"Connection failed! Error - %@ %@",
			  [error localizedDescription],
			  [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
		NSLog(@"error code: %d", [error code]);
	}
}

- (void)setNetwork:(NSDictionary *)aNetwork
{
	selectedNetwork = aNetwork;
	[InfoArray removeAllObjects];
	
	for (id key in selectedNetwork) {
		NSLog(@"key: %@, value: %@", key, [selectedNetwork objectForKey:key]);
	}
	
	if([selectedNetwork objectForKey: @"SSID_STR"]!=nil) {
		NSString *tmp = [NSString localizedStringWithFormat:@"SSID: %@", [selectedNetwork objectForKey: @"SSID_STR"]];
		[InfoArray addObject: tmp];
		self.ssid = [selectedNetwork objectForKey: @"SSID_STR"];
	}
	
	if([selectedNetwork objectForKey: @"RSSI"]!=nil) {
		NSString *value = [NSString localizedStringWithFormat:@"%@", [selectedNetwork objectForKey: @"RSSI"]];
		int RSSI = [value intValue]+127;;
		NSString *tmp = [NSString localizedStringWithFormat:@"Signal Strength: %d", RSSI];
		[InfoArray addObject: tmp];
	}
	
	if([selectedNetwork objectForKey: @"AP_MODE"]!=nil) {
		switch([[selectedNetwork objectForKey: @"AP_MODE"] integerValue]) {
			case 0:
				[InfoArray addObject: @"AP_MODE: Unknown"];
				break;
			case 1:
				[InfoArray addObject: @"AP_MODE: Ad-hoc"];
				break;
			case 2:
				[InfoArray addObject: @"AP_MODE: AP"];
				break;
		}
	}
	
	[InfoArray addObject: [[selectedNetwork objectForKey:@"WEP"] boolValue] ? @"WEP: YES":@"WEP: NO"];
	
	if([selectedNetwork objectForKey:@"WPA_IE"]!=nil)
		[InfoArray addObject: @"WPA-1: YES"];
	
	if([selectedNetwork objectForKey:@"RSN_IE"]!=nil)
		[InfoArray addObject: @"WPA-2: YES"];
	
	if([selectedNetwork objectForKey: @"BSSID"]!=nil) {
		NSString *tmp = [NSString localizedStringWithFormat:@"BSSID: %@", 
						 [selectedNetwork objectForKey: @"BSSID"]];
		[InfoArray addObject: tmp];
	}
	
	//query database
	NSLog(@"Queryed SSID_STR: %@", [selectedNetwork objectForKey: @"SSID_STR"]);
	
	if(Db==nil)
		NSLog(@"DbObject Error");
	else {
		self.wificonfig = [Db queryDatabase:[selectedNetwork objectForKey: @"SSID_STR"]];
	
		if([self.wificonfig count]>0) 
		{
			NSLog(@"%d", [self.wificonfig count]);
			//has record inside
			self.navigationItem.rightBarButtonItem = associateBtn;
			self.navigationItem.leftBarButtonItem = delBtn;
		} else {
			NSLog(@"No Profile!");
			// build a new profile
			[self.wificonfig removeAllObjects];
			// add SSID first
			[self.wificonfig addObject: [selectedNetwork objectForKey: @"SSID_STR"]];
			self.navigationItem.rightBarButtonItem = profileBtn;
		}
	}
	
	[tableView reloadData];
}

- (void)reloadTableData
{
	[tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Number of sections is the number of region dictionaries
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of names in the region dictionary for the specified section
	return [InfoArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"] autorelease];
    }
	
    NSString *cellValue = [InfoArray objectAtIndex:indexPath.row];
	[cell.textLabel setText: cellValue];
	cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

@end
