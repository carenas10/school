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

- (NSArray *)getSettings{
    NSMutableArray *retval = [[NSMutableArray alloc]init];
    
    NSString *query = @"SELECT * FROM settingsTable";
    
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

            //init new vidSetting
            //VidSetting *newSetting = [[VidSetting alloc]initWithID:set_ID name:name resolution:resolution bitrate:bitrate framerate:framerate vidCodec:vidCodec audioCodec:audioCodec];
            VidSetting *newSetting = [[VidSetting alloc]initWithID:set_ID name:name resolution:resolution bitrate:bitrate framerate:framerate vidCodec:vidCodec audioCodec:audioCodec];
            [retval addObject:newSetting];

        }//while
    }//if
    return retval;
}//getSettings

//get setting with given ID in db
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
            
            /*
            char *nameChars = (char *)sqlite3_column_text(statement, 1);
            NSString *name = [[NSString alloc] initWithUTF8String:nameChars];
            
            char *resolutionChars = (char *)sqlite3_column_text(statement, 2);
            NSString *resolution = [[NSString alloc]initWithUTF8String:resolutionChars];
            */
            int bitrate = sqlite3_column_int(statement,3);
            int framerate = sqlite3_column_int(statement,4);
            int vidCodec = sqlite3_column_int(statement,5);
            int audioCodec = sqlite3_column_int(statement,6);
            
            //init new vid setting
            newSetting = [[VidSetting alloc]initWithID:setting_ID name:name resolution:resolution bitrate:bitrate framerate:framerate vidCodec:vidCodec audioCodec:audioCodec];
        }//if
    }//if
    return newSetting;
}//settingWithID

//add a new setting to the settingsTable in the db
-(BOOL)addSetting:(VidSetting *)setting{
    NSString* settingName = setting.name;
    NSString* resolution = setting.resolution;
    int bitrate = setting.bitrate;
    int framerate = setting.framerate;
    int vidCodec = setting.vidCodec;
    int audioCodec = setting.audioCodec;
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO settingsTable(name,resolution,bitrate,framerate,vidCodec,audioCodec) VALUES ('%@','%@',%d,%d,%d,%d)",settingName,resolution,bitrate,framerate,vidCodec,audioCodec];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK){
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        return YES;
    } else {
        NSLog(@"Unable to prepare statement - %@",[NSString stringWithFormat:@"INSERT INTO settingsTable(name,resolution,bitrate,framerate,vidCodec,audioCodec) VALUES ('%@','%@',%d,%d,%d,%d)",settingName,resolution,bitrate,framerate,vidCodec,audioCodec]);
        sqlite3_finalize(statement);
        return NO;
    }
}//addSetting

//update a given setting
-(BOOL)updateSetting:(int)setting_ID name:(NSString *)name resolution:(NSString *)resolution bitrate:(int)bitrate framerate:(int)framerate vidCodec:(int)vidCodec audioCodec:(int)audioCodec{
    
    NSString *query = [NSString stringWithFormat:@"UPDATE settingsTable SET name='%@', resolution='%@', bitrate=%d, framerate=%d, vidCodec=%d, audioCodec=%d where setting_ID=%d",name,resolution,bitrate,framerate,vidCodec,audioCodec,setting_ID];
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

-(BOOL)removeSetting:(int)setting_ID{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM settingsTable WHERE setting_ID=%d",setting_ID];
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

@end