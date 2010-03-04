//
//  WifiDataBase.m
//  wireless
//
//  Created by Mac on 2009/9/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WifiDataBase.h"

@implementation WifiDataBase

- (id)init
{
	self = [super init];
	[self createDatabaseIfNeeded];
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createDatabaseIfNeeded {
	NSLog(@"createDatabaseIfNeeded");
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"wifidb.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"wifidb.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)InstallNewDatabase {
	NSLog(@"InstallNewDatabase");
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"wifidb.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
	
    if (success) {
		NSLog(@"database exist!");
		BOOL delok;
		delok = [fileManager removeItemAtPath:writableDBPath error:&error];
		if(!delok)
			NSLog(@"Failed to delete database file with message '%@'.", [error localizedDescription]);
	}
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"wifidb.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}


// Open the database connection and retrieve minimal information for all objects.
- (NSMutableArray *) queryDatabase : (NSString*) ssid
{
	NSLog(@"queryDatabase");
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"wifidb.sqlite"];
	
	NSMutableArray *wifiInfo = [NSMutableArray array];
	
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &wifi_db) == SQLITE_OK) {
		NSLog(@"SQLITE_OK");
        // Get the primary key for all books.
        const char *sql = "SELECT * FROM wifidb WHERE ssid=?";
		NSLog(@"query str = %s", sql);
		
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
        if (sqlite3_prepare_v2(wifi_db, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We "step" through the results - once for each row.
			
			// For this query, we bind the primary key to the first (and only) placeholder in the statement.
			// Note that the parameters are numbered from 1, not from 0.
			sqlite3_bind_text(statement, 1, [ssid UTF8String], -1, SQLITE_TRANSIENT);
			
			if (sqlite3_step(statement) == SQLITE_ROW) {
				
				NSLog([NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]);
				NSLog([NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]);
				NSLog([NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]);
				NSLog([NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]);
				NSLog([NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]);
				NSLog([NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)]);
				int auth = sqlite3_column_int(statement, 6);
				NSLog(@"auth = %d", auth);
				
				[wifiInfo addObject: [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
				[wifiInfo addObject: [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
				[wifiInfo addObject: [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]];
				[wifiInfo addObject: [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]];
				[wifiInfo addObject: [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]];
				[wifiInfo addObject: [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)]];
				[wifiInfo addObject: [NSString stringWithFormat: @"%d", sqlite3_column_int(statement, 6)]];
				
			} else {
				NSLog(@"Nothing");
			}
			
        }
        // Reset the statement for future reuse.
        sqlite3_reset(statement);
		
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(wifi_db);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(wifi_db));
        // Additional error handling, as appropriate...
    }
	
	return wifiInfo;
}

- (Boolean) delEntryToDatabase :(NSString*) ssid
{
	NSLog(@"Del Entry To Database by SSID");
	// The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"wifidb.sqlite"];
	
	// Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &wifi_db) == SQLITE_OK) {
		NSLog(@"SQLITE_OK");
        // Get the primary key for all books.
        const char *sql = "delete from wifidb where ssid = ?;";
		NSLog(@"query str = %s", sql);
		
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
        if (sqlite3_prepare_v2(wifi_db, sql, -1, &statement, NULL) == SQLITE_OK) {
            
			sqlite3_bind_text(statement, 1, [ssid UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_step(statement);
        }
        // Reset the statement for future reuse.
        sqlite3_reset(statement);
		return YES;
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(wifi_db);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(wifi_db));
		return NO;
    }
}

// Open the database connection and retrieve minimal information for all objects.
- (void) addEntryToDatabase :(NSString*) ssid:(NSString* ) weppass
							:(NSString* ) url: (NSString*) postStr
							:(NSString* ) username: (NSString* ) userpass: (NSString* ) authtype
{
	NSLog(@"Add New Entry To Database");
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"wifidb.sqlite"];
	
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &wifi_db) == SQLITE_OK) {
		NSLog(@"SQLITE_OK");
        // Get the primary key for all books.
        const char *sql = "insert into wifidb(ssid,weppass,url,poststr,user,pass,auth) values (?,?,?,?,?,?,?);";
		NSLog(@"query str = %s", sql);
		
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
        if (sqlite3_prepare_v2(wifi_db, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We "step" through the results - once for each row.
			
			// For this query, we bind the primary key to the first (and only) placeholder in the statement.
			// Note that the parameters are numbered from 1, not from 0.
			sqlite3_bind_text(statement, 1, [ssid UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 2, [weppass UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 3, [url UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 4, [postStr UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 5, [username UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 6, [userpass UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 7, [authtype UTF8String], -1, SQLITE_TRANSIENT);
			
			if (sqlite3_step(statement) == SQLITE_ROW) {
				NSLog(@"Modified One Row");
			} else {
				NSLog(@"Did not Modified");
			}
			
        }
        // Reset the statement for future reuse.
        sqlite3_reset(statement);
		
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(wifi_db);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(wifi_db));
        // Additional error handling, as appropriate...
    }
}


@end
