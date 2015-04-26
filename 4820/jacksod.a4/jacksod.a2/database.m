#import "Database.h"

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

//===============================Settings Methods==========================================

//Gets the settings from the local DB.
//MOD
- (NSArray *)getSettings{
    NSMutableArray *retval = [[NSMutableArray alloc]init];
    
    NSString *query = @"SELECT * FROM settingsTable WHERE is_deleted='FALSE' ";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)==SQLITE_OK) {
        while(sqlite3_step(statement)==SQLITE_ROW){
            //interpret each column.
            int set_ID = sqlite3_column_int(statement, 0);
            
            NSString *name = nil;
            char *nameChars = (char *)sqlite3_column_text(statement, 1);
            if (nameChars != NULL)
                name = [[NSString alloc] initWithUTF8String:nameChars];
            
            NSString *resolution = nil;
            char *resolutionChars = (char *)sqlite3_column_text(statement, 2);
            if (resolutionChars != NULL)
                resolution = [[NSString alloc]initWithUTF8String:resolutionChars];

            int bitrate = sqlite3_column_int(statement,3);
            int framerate = sqlite3_column_int(statement,4);
            int vidCodec = sqlite3_column_int(statement,5);
            int audioCodec = sqlite3_column_int(statement,6);
            int GID = sqlite3_column_int(statement,7);
            BOOL is_deleted = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)] isEqualToString:@"TRUE"];

            VidSetting *newSetting = [[VidSetting alloc]initWithID:set_ID name:name resolution:resolution bitrate:bitrate framerate:framerate vidCodec:vidCodec audioCodec:audioCodec GID:GID is_deleted:is_deleted];
            [retval addObject:newSetting];

        }//while
    }//if
    return retval;
}//getSettings

//get setting with given ID in local DB
//MOD
- (VidSetting *)settingWithID:(int)setting_ID{
    VidSetting *newSetting = nil;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM settingsTable WHERE setting_ID=%d",setting_ID];
    
    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)==SQLITE_OK) {
        if(sqlite3_step(statement)==SQLITE_ROW){
            //interpret this column
            int setting_ID = sqlite3_column_int(statement,0);
            
            NSString *name = nil;
            char *nameChars = (char *)sqlite3_column_text(statement, 1);
            if (nameChars != NULL)
                name = [[NSString alloc] initWithUTF8String:nameChars];
            
            NSString *resolution = nil;
            char *resolutionChars = (char *)sqlite3_column_text(statement, 2);
            if (resolutionChars != NULL)
                resolution = [[NSString alloc]initWithUTF8String:resolutionChars];
            
            int bitrate = sqlite3_column_int(statement,3);
            int framerate = sqlite3_column_int(statement,4);
            int vidCodec = sqlite3_column_int(statement,5);
            int audioCodec = sqlite3_column_int(statement,6);
            int GID = sqlite3_column_int(statement, 7);
            BOOL is_deleted = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)] isEqualToString:@"TRUE"];

            
            //init new vid setting
            newSetting = [[VidSetting alloc]initWithID:setting_ID name:name resolution:resolution bitrate:bitrate framerate:framerate vidCodec:vidCodec audioCodec:audioCodec GID:GID is_deleted:is_deleted];
        }//if
    }//if
    return newSetting;
}//settingWithID

//add a new setting to the settingsTable in the local DB
//MOD
-(BOOL)addSetting:(VidSetting *)setting{
    NSString* settingName = setting.name;
    NSString* resolution = setting.resolution;
    int bitrate = setting.bitrate;
    int framerate = setting.framerate;
    int vidCodec = setting.vidCodec;
    int audioCodec = setting.audioCodec;
    int GID = setting.GID;
    BOOL is_deleted = setting.is_deleted;
    NSString *isDeletedString;
    
    if(is_deleted) isDeletedString = @"TRUE"; else isDeletedString=@"FALSE";
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO settingsTable(name,resolution,bitrate,framerate,vidCodec,audioCodec,GID,is_deleted) VALUES ('%@','%@',%d,%d,%d,%d,%d,'%@')",settingName,resolution,bitrate,framerate,vidCodec,audioCodec,GID,isDeletedString];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK){
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        return YES;
    } else {
        NSLog(@"Unable to prepare statement - %@",[NSString stringWithFormat:@"INSERT INTO settingsTable(name,resolution,bitrate,framerate,vidCodec,audioCodec,GID,is_deleted) VALUES ('%@','%@',%d,%d,%d,%d,%d,'%@')",settingName,resolution,bitrate,framerate,vidCodec,audioCodec,GID,isDeletedString]);
        
        sqlite3_finalize(statement);
        return NO;
    }
}//addSetting

//update a given setting
//MOD
-(BOOL)updateSetting:(int)setting_ID name:(NSString *)name resolution:(NSString *)resolution bitrate:(int)bitrate framerate:(int)framerate vidCodec:(int)vidCodec audioCodec:(int)audioCodec GID:(int)GID is_deleted:(BOOL)is_deleted
{
    
    NSString *isDeletedString;
    if(is_deleted) isDeletedString = @"TRUE"; else isDeletedString = @"FALSE";
    
    NSString *query = [NSString stringWithFormat:@"UPDATE settingsTable SET name='%@', resolution='%@', bitrate=%d, framerate=%d, vidCodec=%d, audioCodec=%d, GID=%d, is_deleted='%@' where setting_ID=%d",name,resolution,bitrate,framerate,vidCodec,audioCodec,GID,isDeletedString,setting_ID];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK){
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        return YES;
    } else {
        sqlite3_finalize(statement);
        return NO;
    }
}//updateSetting

//sets the is_deleted field to true, instead of removing the record.
//MOD
-(BOOL)removeSetting:(int)setting_ID{
    NSString *query = [NSString stringWithFormat:@"UPDATE settingsTable SET is_deleted='TRUE' WHERE setting_ID=%d",setting_ID];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK){
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        return YES;
    } else {
        sqlite3_finalize(statement);
        return NO;
    }

}

//GID OPS

//sets the GID for a specific setting
-(BOOL)setSettingGID:(VidSetting *)setting GID:(int)GID{
    
    int settingID = setting.setting_ID;
    NSString *query = [NSString stringWithFormat:@"UPDATE settingsTable SET GID=%d WHERE setting_ID=%d",GID,settingID];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK){
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        return YES;
    } else {
        NSLog(@"Unable to set Route GID: %s", sqlite3_errmsg(_database));
        sqlite3_finalize(statement);
        return NO;
    }
}

//using the GID, returns the setting_ID from the local storage.
-(int)getSettingIDfromGID:(int)GID{
    int rowID = -1;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM settingsTable WHERE GID=%d", GID];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            rowID = sqlite3_column_int(statement, 0);
        } else NSLog(@"Failed to return route from GID: %s",sqlite3_errmsg(_database));
        sqlite3_finalize(statement);
    }
    else NSLog(@"Failed to return route from GID: %s",sqlite3_errmsg(_database));
    return rowID;
}



//===============================Codec Methods==========================================

- (NSArray *)getVideoCodecs{
    NSMutableArray *retval = [[NSMutableArray alloc]init];
    
    NSString *query = @"SELECT * FROM videoCodecs";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)==SQLITE_OK) {
        while(sqlite3_step(statement)==SQLITE_ROW){
            //interpret each column.
            int codec_ID = sqlite3_column_int(statement, 0);
            
            NSString *codecName = nil;
            char *codecNameChars = (char *)sqlite3_column_text(statement, 1);
            if (codecNameChars != NULL)
                codecName = [[NSString alloc] initWithUTF8String:codecNameChars];
            
            //init new codec
            Codec *newCodec = [[Codec alloc]initWithID:codec_ID name:codecName];
            
            [retval addObject:newCodec];
            
        }//while
    }//if
    return retval;
}

-(Codec *)videoCodecWithID:(int)vidCodecID{
    Codec *retCodec = nil;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM videoCodecs WHERE vidCodec_ID=%d",vidCodecID];
    
    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)==SQLITE_OK) {
        if(sqlite3_step(statement)==SQLITE_ROW){
            //interpret this column
            int codec_ID = sqlite3_column_int(statement, 0);
            
            NSString *codecName = nil;
            char *codecNameChars = (char *)sqlite3_column_text(statement, 1);
            if (codecNameChars != NULL)
                codecName = [[NSString alloc] initWithUTF8String:codecNameChars];
            
            /*
            char *codecNameChars = (char *)sqlite3_column_text(statement, 1);
            NSString *codecName = [[NSString alloc] initWithUTF8String:codecNameChars];*/
            
            //init new codec
            retCodec = [[Codec alloc]initWithID:codec_ID name:codecName];
        }//if
    }//if
    return retCodec;
}

- (NSArray *)getAudioCodecs{
    NSMutableArray *retval = [[NSMutableArray alloc]init];
    
    NSString *query = @"SELECT * FROM audioCodecs";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)==SQLITE_OK) {
        while(sqlite3_step(statement)==SQLITE_ROW){
            //interpret each column.
            int codec_ID = sqlite3_column_int(statement, 0);
            
            NSString *codecName = nil;
            char *codecNameChars = (char *)sqlite3_column_text(statement, 1);
            if (codecNameChars != NULL)
                codecName = [[NSString alloc] initWithUTF8String:codecNameChars];
            
            /*
            char *codecNameChars = (char *)sqlite3_column_text(statement, 1);
            NSString *codecName = [[NSString alloc] initWithUTF8String:codecNameChars];*/
            
            //init new codec
            Codec *newCodec = [[Codec alloc]initWithID:codec_ID name:codecName];
            
            [retval addObject:newCodec];
            
        }//while
    }//if
    return retval;
}

-(Codec *)audioCodecWithID:(int)audioCodecID{
    Codec *retCodec = nil;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM audioCodecs WHERE audioCodec_ID=%d",audioCodecID];
    
    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)==SQLITE_OK) {
        if(sqlite3_step(statement)==SQLITE_ROW){
            //interpret this column
            int codec_ID = sqlite3_column_int(statement, 0);
            
            NSString *codecName = nil;
            char *codecNameChars = (char *)sqlite3_column_text(statement, 1);
            if (codecNameChars != NULL)
                codecName = [[NSString alloc] initWithUTF8String:codecNameChars];
            
            /*
            char *codecNameChars = (char *)sqlite3_column_text(statement, 1);
            NSString *codecName = [[NSString alloc] initWithUTF8String:codecNameChars];*/
            
            //init new codec
            retCodec = [[Codec alloc]initWithID:codec_ID name:codecName];
        }//if
    }//if
    return retCodec;
}

-(NSArray *)getUnsyncedSettings{
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT * FROM settingsTable where GID=-1";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //interpret each column.
            int set_ID = sqlite3_column_int(statement, 0);
            
            NSString *name = nil;
            char *nameChars = (char *)sqlite3_column_text(statement, 1);
            if (nameChars != NULL)
                name = [[NSString alloc] initWithUTF8String:nameChars];
            
            NSString *resolution = nil;
            char *resolutionChars = (char *)sqlite3_column_text(statement, 2);
            if (resolutionChars != NULL)
                resolution = [[NSString alloc]initWithUTF8String:resolutionChars];
            
            int bitrate = sqlite3_column_int(statement,3);
            int framerate = sqlite3_column_int(statement,4);
            int vidCodec = sqlite3_column_int(statement,5);
            int audioCodec = sqlite3_column_int(statement,6);
            int GID = sqlite3_column_int(statement,7);
            BOOL is_deleted = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)] isEqualToString:@"TRUE"];
            
            VidSetting *newSetting = [[VidSetting alloc]initWithID:set_ID name:name resolution:resolution bitrate:bitrate framerate:framerate vidCodec:vidCodec audioCodec:audioCodec GID:GID is_deleted:is_deleted];
            [retval addObject:newSetting];

        }
        sqlite3_finalize(statement);
    }
    return retval;
}//getUnsyncedSettings

-(NSArray *)getDeletedSettings{
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT * FROM settingsTable WHERE is_deleted='TRUE'";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //interpret each column.
            int set_ID = sqlite3_column_int(statement, 0);
            
            NSString *name = nil;
            char *nameChars = (char *)sqlite3_column_text(statement, 1);
            if (nameChars != NULL)
                name = [[NSString alloc] initWithUTF8String:nameChars];
            
            NSString *resolution = nil;
            char *resolutionChars = (char *)sqlite3_column_text(statement, 2);
            if (resolutionChars != NULL)
                resolution = [[NSString alloc]initWithUTF8String:resolutionChars];
            
            int bitrate = sqlite3_column_int(statement,3);
            int framerate = sqlite3_column_int(statement,4);
            int vidCodec = sqlite3_column_int(statement,5);
            int audioCodec = sqlite3_column_int(statement,6);
            int GID = sqlite3_column_int(statement,7);
            BOOL is_deleted = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)] isEqualToString:@"TRUE"];
            
            VidSetting *newSetting = [[VidSetting alloc]initWithID:set_ID name:name resolution:resolution bitrate:bitrate framerate:framerate vidCodec:vidCodec audioCodec:audioCodec GID:GID is_deleted:is_deleted];
            [retval addObject:newSetting];
        }
        sqlite3_finalize(statement);
    }
    else NSLog(@"Failed to get deleted settings: %s", sqlite3_errmsg(_database));
    return retval;
}//getDeletedSettings


@end