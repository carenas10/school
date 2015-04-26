/*
Jackson Dawkins
 
Video Setting interface
    A Video setting in the professional world is also known as the encoding set.
    This "setting" stores some primary information needed to encode a video
    This type will provide some basic functionality of a video setting.
*/

#import <Foundation/Foundation.h>

@interface VidSetting : NSObject

@property (nonatomic,assign) int setting_ID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *resolution;
@property (nonatomic) int bitrate;
@property (nonatomic) int framerate;
@property (nonatomic) int vidCodec;
@property (nonatomic) int audioCodec;

- (id)initWithID:(int)setting_Id
            name:(NSString *)name
      resolution:(NSString *)resolution
         bitrate:(int)bitrate
       framerate:(int)framerate
        vidCodec:(int)vidCodec
      audioCodec:(int)audioCodec;

@end