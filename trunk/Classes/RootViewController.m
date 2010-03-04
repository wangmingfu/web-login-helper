//
//  RootViewController.m
//  Web Login Helper
//
//  Created by Mac on 2010/1/31.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "TableViewAppDelegate.h"
#import "DetailViewController.h"
#import "Scanner.h"
#import "WifiDataBase.h"

@implementation RootViewController

// @synthesize DbObject;

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	//Initialize the array.
	listOfItems = [[NSMutableArray alloc] init];
	Sec_List = [[NSMutableArray alloc] init];
	Info_List = [[NSMutableArray alloc] init];
	
	// Install database
	DbObject = [[WifiDataBase alloc]init];
	
	WScanner = [[MSNetworksManager alloc]init];
	char power;
	
	int err = [WScanner getPower:&power];
	if (err)
		NSLog(@"Apple80211GetPower failed: %d",err);
	NSLog(@"Wifi Power=%d", power);
	
	// Set Off->On
	if(!power) 
	{
		power = 1;
		err = [WScanner setPower:&power];
		if (err)
			NSLog(@"Apple80211SetPower failed: %d",err);
	}
	
	[WScanner scan];
	NSArray *networks = [[WScanner networks] allValues];
	
	for(int i=0;i<[networks count];i++) {
		
		NSDictionary *net = [networks objectAtIndex: i];
		
		// List all informaiton for debug
		NSLog(@"SSID_STR: %@", [net objectForKey: @"SSID_STR"]);
		NSLog(@"WEP: %@", [net objectForKey: @"WEP"]);
		NSLog(@"RSSI: %@", [net objectForKey: @"RSSI"]);
		NSLog(@"AP_MODE: %@", [net objectForKey: @"AP_MODE"]);
		NSLog(@"SSID: %@", [net objectForKey: @"SSID"]);
		NSLog(@"CHANNEL: %@", [net objectForKey: @"CHANNEL"]);
		NSLog(@"BSSID: %@", [net objectForKey: @"BSSID"]);
		NSLog(@"AGE: %@", [net objectForKey: @"AGE"]);
		NSLog(@"NOISE: %@", [net objectForKey: @"NOISE"]);
		NSLog(@"RSN_IE: %@", [net objectForKey: @"RSN_IE"]);
		NSLog(@"CAPABILITIES: %@", [net objectForKey: @"CAPABILITIES"]);
		NSLog(@"scanWasDirected: %@", [net objectForKey: @"scanWasDirected"]);
		NSLog(@"IE: %@", [net objectForKey: @"IE"]);
		NSLog(@"APPLE_IE: %@", [net objectForKey: @"APPLE_IE"]);
		NSLog(@"WPA_IE: %@", [net objectForKey: @"WPA_IE"]);
		
		if ([net objectForKey: @"SSID_STR"]==nil)
			[listOfItems addObject: @"<hidden>"];
		else
			[listOfItems addObject: [net objectForKey: @"SSID_STR"]];
		
		NSString* sec_type = @"";
		if([[net objectForKey:@"WEP"] boolValue])
			sec_type = @"WEP";
		else if([net objectForKey:@"WPA_IE"]!=nil)
			sec_type = @"WPA-1";
		else if([net objectForKey:@"RSN_IE"]!=nil)
			sec_type = @"WPA-2";
		else
			sec_type = @"OPEN";
		
		[Sec_List addObject: sec_type];
		
		NSString *value = [NSString localizedStringWithFormat:@"%@", [net objectForKey: @"RSSI"]];
		int RSSI = [value intValue]+127;;
		NSString *iStr = 
		[NSString localizedStringWithFormat:@"RSSI: %d, Security: %@", RSSI, sec_type];
		[Info_List addObject:iStr];
	}
	
	//Set the title
	self.navigationItem.title = @"Scanned AP List";
	
	// add scan button
	scanBtn = [[UIBarButtonItem alloc] initWithTitle:@"ReScan" style:UIBarButtonItemStylePlain 
											  target:self action:@selector(toggleScan:)];
	self.navigationItem.leftBarButtonItem = scanBtn;
}

- (void)toggleScan:(id)sender
{
	[scanBtn setEnabled:FALSE];
	NSLog(@"ReScan");
	
	[listOfItems removeAllObjects];
	
	[WScanner removeAllNetworks];
	[WScanner scan];
	NSArray *networks = [[WScanner networks] allValues];
	
	for(int i=0;i<[networks count];i++) {
		NSDictionary *net = [networks objectAtIndex: i];
		
		if ([net objectForKey: @"SSID_STR"]==nil)
			[listOfItems addObject: @"<hidden>"];
		else
			[listOfItems addObject: [net objectForKey: @"SSID_STR"]];
		
		NSString* sec_type = @"";
		if([[net objectForKey:@"WEP"] boolValue])
			sec_type = @"WEP";
		else if([net objectForKey:@"WPA_IE"]!=nil)
			sec_type = @"WPA-1";
		else if([net objectForKey:@"RSN_IE"]!=nil)
			sec_type = @"WPA-2";
		else
			sec_type = @"OPEN";
		
		[Sec_List addObject: sec_type];
		
		NSString *value = [NSString localizedStringWithFormat:@"%@", [net objectForKey: @"RSSI"]];
		int RSSI = [value intValue]+127;;
		NSString *iStr = 
		[NSString localizedStringWithFormat:@"RSSI: %d, Security: %@", 
		 RSSI, sec_type];
		[Info_List addObject:iStr];
		
	}
	
	[self.tableView reloadData];
	[scanBtn setEnabled:TRUE];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listOfItems count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
									  reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	[cell.textLabel setText: [listOfItems objectAtIndex:indexPath.row]];
	[cell.detailTextLabel setText: [Info_List objectAtIndex:indexPath.row]];
	cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
	
	NSString *type = [Sec_List objectAtIndex:indexPath.row];
	NSString *path = nil;
	UIImage *theImage = nil;
	
	if(type==@"WPA-1"||type==@"WPA-2")
	{
		path = [[NSBundle mainBundle] pathForResource:@"WPA" ofType:@"png"];
		theImage = [UIImage imageWithContentsOfFile:path];
	}else if(type==@"WEP") {
		path = [[NSBundle mainBundle] pathForResource:@"WEP" ofType:@"png"];
		theImage = [UIImage imageWithContentsOfFile:path];
	}else if(type==@"OPEN"){
		path = [[NSBundle mainBundle] pathForResource:@"OPEN" ofType:@"png"];
		theImage = [UIImage imageWithContentsOfFile:path];
	}
	
	if(theImage!=nil)
		cell.imageView.image = theImage;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//Get the selected country
	NSString *selectedAP = [listOfItems objectAtIndex:indexPath.row];
	
	NSLog(@"selectedAP = %@", selectedAP );
	NSLog(@"indexPath = %d", indexPath.row );
	
	//Initialize the detail view controller and display it.
	DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	
	// dvController.selectedAP = selectedAP;
	[self.navigationController pushViewController:dvController animated:YES];
	
	NSDictionary *net = [[[WScanner networks]allValues]objectAtIndex:indexPath.row];
	
	// [dvController setDBObject: self.DbObject];
	[dvController setNetwork: net];
	[dvController setScanner: WScanner];
	
	[dvController release];
	dvController = nil;
}

/*
 - (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
 
 //return UITableViewCellAccessoryDetailDisclosureButton;
 return UITableViewCellAccessoryDisclosureIndicator;
 }
 */

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)dealloc {
	[DbObject dealloc];
	[scanBtn release];
	[WScanner release];
	[listOfItems release];
	[Sec_List release];
	[Info_List release];
    [super dealloc];
}


@end

