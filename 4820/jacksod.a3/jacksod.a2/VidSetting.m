#import "VidSetting.h"

@implementation VidSetting

@synthesize setting_ID = _setting_ID;
@synthesize name = _name;
@synthesize resolution = _resolution;
@synthesize bitrate = _bitrate;
@synthesize framerate = _framerate;
@synthesize vidCodec = _vidCodec;
@synthesize audioCodec = _audioCodec;

- (id)initWithID:(int)setting_ID name:(NSString *)name resolution:(NSString *)resolution bitrate:(int)bitrate framerate:(int)framerate vidCodec:(int)vidCodec audioCodec:(int)audioCodec
{
    if((self = [super init])){
        self.setting_ID=setting_ID;
        self.name=name;
        self.resolution=resolution;
        self.bitrate=bitrate;
        self.framerate=framerate;
        self.vidCodec=vidCodec;
        self.audioCodec=audioCodec;
    }
    return self;
}//init


@end