//
//  VideoCodec.m
//  jacksod.a2
//
//  Created by Jake Dawkins on 10/9/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

#import "Codec.h"

@implementation Codec

@synthesize codec_ID = _codec_ID;
@synthesize codecName = _codecName;

- (id)initWithID:(int)vidCodec_ID name:(NSString *)vidCodecName{
    if(self = [super init]){
        self.codec_ID = vidCodec_ID;
        self.codecName = vidCodecName;
    }
    return self;
}

@end