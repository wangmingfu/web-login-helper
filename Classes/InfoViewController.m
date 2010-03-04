//
//  InfoViewController.m
//  UINavigationControllerWithToolbar
//
//  Created by iPhone SDK Articles on 9/16/08.
//  Copyright www.iPhoneSDKArticles.com 2008. All rights reserved.
//

#import "InfoViewController.h"
#import "WifiDataBase.h"

#define kTextFieldWidth	260.0

#define kLeftMargin				20.0
#define kTopMargin				20.0
#define kRightMargin			20.0
#define kTweenMargin			10.0

#define kTextFieldHeight		30.0

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";

const NSInteger kViewTag = 1;

@implementation InfoViewController

@synthesize isViewPushed;
@synthesize textFieldURL, textFieldPostStr, textFieldUser, textFieldPasswd;
@synthesize dataSourceArray;
@synthesize weppass, ssid;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	
	if(isViewPushed == NO) {
		
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
			initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
			target:self action:@selector(cancel_Clicked:)] autorelease];
		
		// add scan button
		UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain 
												  target:self action:@selector(save_Clicked:)];
		self.navigationItem.rightBarButtonItem = saveBtn;
		
		self.dataSourceArray = [NSArray arrayWithObjects:
								[NSDictionary dictionaryWithObjectsAndKeys:
								 @"PostURL", kSectionTitleKey,
								 @"PostURL should be strated with http or https prefixes", kSourceKey,
								 self.textFieldURL, kViewKey,
								 nil],
								
								[NSDictionary dictionaryWithObjectsAndKeys:
								 @"PostString", kSectionTitleKey,
								 @"POST String for user login", kSourceKey,
								 self.textFieldPostStr, kViewKey,
								 nil],
								
								[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UserName", kSectionTitleKey,
								 @"WebLogIn UserName", kSourceKey,
								 self.textFieldUser, kViewKey,
								 nil],
								
								[NSDictionary dictionaryWithObjectsAndKeys:
								 @"Passwd", kSectionTitleKey,
								 @"WebLogIn Passwords", kSourceKey,
								 self.textFieldPasswd, kViewKey,
								 nil],
								
								nil];
		
		self.title = NSLocalizedString(@"Configuration Setup", @"");
		
		// we aren't editing any fields yet, it will be in edit when the user touches an edit field
		self.editing = NO;
	}
}

- (void) setupWifiParameters: (NSString* ) ssidtag: (NSString* ) pass: (NSString* ) url
{
	self.ssid = ssidtag;
	NSLog(@"Received SSID: %@", self.ssid);
	self.weppass = pass;
	NSLog(@"Received WEPPASS: %@", self.weppass);
	textFieldURL.text = url;
	NSLog(@"Received url: %@", url);
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// release the controls and set them nil in case they were ever created
	// note: we can't use "self.xxx = nil" since they are read only properties
	//
	[textFieldURL release];
	textFieldURL = nil;		
	[textFieldPostStr release];
	textFieldPostStr = nil;
	[textFieldUser release];
	textFieldUser = nil;
	[textFieldPasswd release];
	textFieldPasswd = nil;
	
	self.dataSourceArray = nil;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.dataSourceArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.dataSourceArray objectAtIndex: section] valueForKey:kSectionTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

// to determine specific row height for each cell, override this.
// In this example, each row is determined by its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ([indexPath row] == 0) ? 50.0 : 22.0;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	NSUInteger row = [indexPath row];
	if (row == 0)
	{
		static NSString *kCellTextField_ID = @"CellTextField_ID";
		cell = [tableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
		if (cell == nil)
		{
			// a new cell needs to be created
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellTextField_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else
		{
			// a cell is being recycled, remove the old edit field (if it contains one of our tagged edit fields)
			UIView *viewToCheck = nil;
			viewToCheck = [cell.contentView viewWithTag:kViewTag];
			if (!viewToCheck)
				[viewToCheck removeFromSuperview];
		}
		
		UITextField *textField = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kViewKey];
		[cell.contentView addSubview:textField];
	}
	else /* (row == 1) */
	{
		static NSString *kSourceCell_ID = @"SourceCell_ID";
		cell = [tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCell_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.highlightedTextColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
		}
		
		cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kSourceKey];
	}
	
    return cell;
}


-(void) viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
}


-(void) cancel_Clicked:(id)sender {

	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void) save_Clicked:(id)sender {
	
	// Save configuration file
	NSLog(@"Sqlite-SSID:%@", self.ssid);
	NSLog(@"Sqlite-WEPPASS:%@", self.weppass);
	NSLog(@"Sqlite-URL:%@", self.textFieldURL.text);
	NSLog(@"Sqlite-SSID:%@", self.textFieldPostStr.text);
	NSLog(@"Sqlite-USER:%@", self.textFieldUser.text);
	NSLog(@"Sqlite-USERPASS:%@", self.textFieldPasswd.text);
	
	Db = [[WifiDataBase alloc]init];
	
	if(self.ssid!=nil) {
		if(self.weppass!=nil) {
			// wep enabled
			NSLog(@"WEP.");
			if((self.textFieldURL.text!=nil)&&(self.textFieldPostStr.text!=nil)&&
			   (self.textFieldUser.text!=nil)&&(self.textFieldPasswd.text!=nil)) {
				// url authentication
				NSLog(@"url auth.");
				// case 3
				[Db addEntryToDatabase: self.ssid: self.weppass: 
				 self.textFieldURL.text: self.textFieldPostStr.text: 
				 self.textFieldUser.text: self.textFieldPasswd.text : @"3"];
			}else {
				NSLog(@"No url auth.");
				// case 1
				[Db addEntryToDatabase: self.ssid: self.weppass: @"Null": @"Null": @"Null": @"Null" : @"1"];
			}
		}else {
			NSLog(@"NO WEP.");
			if((self.textFieldURL.text!=nil)&&(self.textFieldPostStr.text!=nil)&&
			   (self.textFieldUser.text!=nil)&&(self.textFieldPasswd.text!=nil)) {
				// url authentication
				NSLog(@"url auth.");
				// case 2
				[Db addEntryToDatabase: self.ssid: @"Null": self.textFieldURL.text: self.textFieldPostStr.text : 
				 self.textFieldUser.text : self.textFieldPasswd.text : @"2"];
			}else {
				NSLog(@"open, No url auth.");
				// case 0
				[Db addEntryToDatabase: self.ssid: @"Null": @"Null": @"Null": @"Null": @"Null" : @"0"];
			}
		}
	}
	
	[self ShowInfoDialog: @"SetConfiguration": @"Add Configuration To Database"];
	
}

- (void) ShowInfoDialog: (NSString*)Title: (NSString*)Message
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
	// Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (UITextField *)textFieldURL
{
	if (textFieldURL == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldURL = [[UITextField alloc] initWithFrame:frame];
		
		textFieldURL.borderStyle = UITextBorderStyleBezel;
		textFieldURL.textColor = [UIColor blackColor];
		textFieldURL.font = [UIFont systemFontOfSize:20.0];
		textFieldURL.placeholder = @"<enter text>";
		textFieldURL.backgroundColor = [UIColor whiteColor];
		textFieldURL.autocorrectionType = UITextAutocorrectionTypeNo;	
		// no auto correction support
		
		textFieldURL.keyboardType = UIKeyboardTypeDefault;	
		// use the default type input method (entire keyboard)
		textFieldURL.returnKeyType = UIReturnKeyDone;
		
		textFieldURL.clearButtonMode = UITextFieldViewModeWhileEditing;	
		// has a clear 'x' button to the right
		
		textFieldURL.tag = kViewTag;		
		// tag this control so we can remove it later for recycled cells
		
		textFieldURL.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldURL setAccessibilityLabel:NSLocalizedString(@"URLTextField", @"")];
	}	
	return textFieldURL;
}

- (UITextField *)textFieldPostStr
{
	if (textFieldPostStr == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldPostStr = [[UITextField alloc] initWithFrame:frame];
		
		textFieldPostStr.borderStyle = UITextBorderStyleRoundedRect;
		textFieldPostStr.textColor = [UIColor blackColor];
		textFieldPostStr.font = [UIFont systemFontOfSize:20.0];
		textFieldPostStr.placeholder = @"<enter text>";
		textFieldPostStr.backgroundColor = [UIColor whiteColor];
		textFieldPostStr.autocorrectionType = UITextAutocorrectionTypeNo;	
		// no auto correction support
		
		textFieldPostStr.keyboardType = UIKeyboardTypeDefault;
		textFieldPostStr.returnKeyType = UIReturnKeyDone;
		
		textFieldPostStr.clearButtonMode = UITextFieldViewModeWhileEditing;	
		// has a clear 'x' button to the right
		
		textFieldPostStr.tag = kViewTag;		
		// tag this control so we can remove it later for recycled cells
		
		textFieldPostStr.delegate = self;	
		// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldPostStr setAccessibilityLabel:NSLocalizedString(@"PostStringTextField", @"")];
	}
	return textFieldPostStr;
}

- (UITextField *)textFieldUser
{
	if (textFieldUser == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldUser = [[UITextField alloc] initWithFrame:frame];
		
		textFieldUser.borderStyle = UITextBorderStyleRoundedRect;
		textFieldUser.textColor = [UIColor blackColor];
		textFieldUser.font = [UIFont systemFontOfSize:20.0];
		textFieldUser.placeholder = @"<enter text>";
		textFieldUser.backgroundColor = [UIColor whiteColor];
		textFieldUser.autocorrectionType = UITextAutocorrectionTypeNo;	
		// no auto correction support
		
		textFieldUser.keyboardType = UIKeyboardTypeDefault;
		textFieldUser.returnKeyType = UIReturnKeyDone;
		
		textFieldUser.clearButtonMode = UITextFieldViewModeWhileEditing;	
		// has a clear 'x' button to the right
		
		textFieldUser.tag = kViewTag;		
		// tag this control so we can remove it later for recycled cells
		
		textFieldUser.delegate = self;	
		// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldUser setAccessibilityLabel:NSLocalizedString(@"UserNameTextField", @"")];
	}
	return textFieldUser;
}

- (UITextField *)textFieldPasswd
{
	if (textFieldPasswd == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldPasswd = [[UITextField alloc] initWithFrame:frame];
		
		textFieldPasswd.borderStyle = UITextBorderStyleRoundedRect;
		textFieldPasswd.textColor = [UIColor blackColor];
		textFieldPasswd.font = [UIFont systemFontOfSize:20.0];
		textFieldPasswd.placeholder = @"<enter text>";
		textFieldPasswd.backgroundColor = [UIColor whiteColor];
		textFieldPasswd.autocorrectionType = UITextAutocorrectionTypeNo;	
		// no auto correction support
		
		textFieldPasswd.keyboardType = UIKeyboardTypeDefault;
		textFieldPasswd.returnKeyType = UIReturnKeyDone;
		
		textFieldPasswd.clearButtonMode = UITextFieldViewModeWhileEditing;	
		// has a clear 'x' button to the right
		
		textFieldPasswd.tag = kViewTag;		
		// tag this control so we can remove it later for recycled cells
		
		textFieldPasswd.delegate = self;	
		// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		textFieldPasswd.secureTextEntry = YES;
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldPasswd setAccessibilityLabel:NSLocalizedString(@"PasswordTextField", @"")];
	}
	return textFieldPasswd;
}


- (void)dealloc {
	
	[Db release];
	
	[textFieldUser release];
	[textFieldPasswd release];
	[textFieldURL release];
	[textFieldPostStr release];
	
	[dataSourceArray release];
	
    [super dealloc];
}


@end
