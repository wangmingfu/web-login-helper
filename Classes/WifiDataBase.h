//
//  WifiDataBase.h
//  wireless
//
//  Created by Mac on 2009/9/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface WifiDataBase : NSObject {
	
	sqlite3 *wifi_db;
	sqlite3_stmt *statement;
}

- (id)init;
- (void)dealloc;

- (void)createDatabaseIfNeeded;
- (void)InstallNewDatabase;
- (NSMutableArray *) queryDatabase : (NSString*) ssid;

- (void) addEntryToDatabase :(NSString*) ssid:(NSString* ) weppass
							:(NSString* ) url: (NSString*) postStr
							:(NSString* ) username: (NSString* ) userpass: (NSString* ) authtype;

- (Boolean) delEntryToDatabase :(NSString*) ssid;

@end
