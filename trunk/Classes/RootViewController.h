//
//  RootViewController.h
//  Web Login Helper
//
//  Created by Mac on 2010/1/31.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class MSNetworksManager;
@class WifiDataBase;

@interface RootViewController : UITableViewController {
	NSMutableArray *listOfItems;
	NSMutableArray *Sec_List;
	NSMutableArray *Info_List;
	
	MSNetworksManager *WScanner;
	UIBarButtonItem *scanBtn;
	WifiDataBase *DbObject;
}

- (void)toggleScan:(id)sender;

@end
