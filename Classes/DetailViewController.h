//
//  DetailViewController.h
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>

@class MSNetworksManager;
@class WifiDataBase;
@class Utility;

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
	UITableView *tableView;
	NSDictionary *selectedNetwork;
	NSMutableArray *InfoArray;
	NSMutableArray *wificonfig;
	
	UIBarButtonItem *associateBtn;
	UIBarButtonItem *profileBtn;
	UIBarButtonItem *delBtn;
	
	MSNetworksManager *Scanner;
	WifiDataBase *Db;
	Utility *util;
	
	int errorcnt;
	
	// For Config Dialog
	UIAlertView *configDialog;
	UITextField *weptext;
	
	NSString *ssid;
	NSString *weppass;
}

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *wificonfig;
@property (nonatomic, retain) NSString *ssid;
@property (nonatomic, retain) NSString *weppass;

- (void)setNetwork:(NSDictionary *)aNetwork;
- (void)setScanner:(MSNetworksManager *)aScanner;
- (void)reloadTableData;
- (void)toggleAssociate:(id)sender;
- (void)toggleNewProfile:(id)sender;
- (void)toggleDelProfile:(id)sender;


- (void)SendAuthPost: (NSString*)URLStr: (NSString*)postData;

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)showPassDialog;

- (NSString*) testConnection: (NSString *)URLStr;
- (void) CreateNewProfile;
- (void) ShowErrorWarning: (NSString*)Title: (NSString*)Message;
- (void) CreateNewFrame: (NSString*) Text;

@end
