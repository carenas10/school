//
//  VideoCodec.h
//  jacksod.a2
//
//  Created by Jake Dawkins on 10/9/14.
//  Copyright (c) 2014 Jake Dawkins. All rights reserved.
//

@interface Codec : NSObject

@property (nonatomic) int codec_ID;
@property (nonatomic) NSString *codecName;


//designated initializer
- (id)initWithID:(int)vidCodec_ID name:(NSString *)vidCodecName;

@end