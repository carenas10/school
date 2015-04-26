@interface Database : NSObject{
    sqlite3 *_database;
}

//initialize using singleton
+ (Database *)database;

//get array of people
-(NSArray *)getSettings;









@end