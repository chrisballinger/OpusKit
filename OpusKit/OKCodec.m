//
//  OKCodec.m
//  OpusKit
//
//  Created by Christopher Ballinger on 2/17/14.
//
//

#import "OKCodec.h"

@implementation OKCodec

- (id) initWithSampleRate:(OpusKitSampleRate)sampleRate numberOfChannels:(OpusKitChannels)channels {
    if (self = [super init]) {
        self.processingQueue = dispatch_queue_create("OpusKit Processing Queue", NULL);
        _sampleRate = sampleRate;
        _numberOfChannels = channels;
    }
    return self;
}

@end
