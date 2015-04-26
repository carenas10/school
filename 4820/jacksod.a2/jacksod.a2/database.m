#import "Database.h"
#import "VidSetting.h"

//#import <Foundation/Foundation.h>

static Database *_database;

@implementation Database

+ (Database *)database {
    if (_database == nil){
        _database = [[Database alloc]init];
    }
    return _database;
}

//initialize DB using singleton pattern
- (id)init {
    if((self = [super init])){
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory  = [paths objectAtIndex:0];
        
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"vtk_db.sqlite"];
        
        //check to make sure database is open and ready.
        if (sqlite3_open([writableDBPath UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}//init

- (void)dealloc {
    sqlite3_close(_database);
}

- (NSArray *)getSettings{
    NSMutableArray *retval = [[NSMutableArray alloc]init];
    
    NSString *query = @"SELECT * FROM settingsTable";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)==SQLITE_OK) {
        while(sqlite3_step(statement)==SQLITE_ROW){
            //interpret each column.
            int rowID = sqlite3_column_int(statement, 0);
            
            char *rowNameChars = (char *)sqlite3_column_text(statement, 1);
            NSString *rowName = [[NSString alloc] initWithUTF8String:rowNameChars];

            /*
            //init person with values from one row of DB, and add to array.
            Person *person = [[Person alloc]initWithId:rowID name:rowName phone:rowPhone email:rowEmail preferredContact:rowPreferredContact birthday:rowBirthday weeklyAvailability:rowWeeklyAvailability shift:rowShift notes:rowNotes];
            [retval addObject:person];
            */
        }//while
    }//if
    
    return retval;

}

@end