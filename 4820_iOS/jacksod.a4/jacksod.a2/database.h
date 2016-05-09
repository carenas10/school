#import "VidSetting.h"
#import "sqlite3.h"
#import "Codec.h"

@interface Database : NSObject{
    sqlite3 *_database;
}

//initialize using singleton
+ (Database *)database;

//get array of settings
-(NSArray *)getSettings;

//array of all video codecs
-(NSArray *)getVideoCodecs;

//array of all audio codecs
-(NSArray *)getAudioCodecs;

//setting modifiers
-(BOOL)addSetting:(VidSetting *)setting;
-(BOOL)updateSetting:(int)setting_ID name:(NSString *)name resolution:(NSString *)resolution bitrate:(int)bitrate framerate:(int)framerate vidCodec:(int)vidCodec audioCodec:(int)audioCodec GID:(int)GID is_deleted:(BOOL)is_deleted;
-(BOOL)removeSetting:(int)setting_ID;

//returns arrays of codecs
-(Codec *)videoCodecWithID:(int)videoCodecID;
-(Codec *)audioCodecWithID:(int)audioCodecID;

// External DB Operations
-(int)getSettingIDfromGID:(int)GID;
-(BOOL)setSettingGID:(VidSetting *)setting GID:(int)GID;
-(NSArray *)getUnsyncedSettings;
-(NSArray *)getDeletedSettings;

@end