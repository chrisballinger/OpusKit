//
//  OKEncoder.h
//  OpusKit
//
//  Created by Christopher Ballinger on 2/17/14.
//
//

#import <Foundation/Foundation.h>
#import "OKCodec.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(int, OpusKitApplication) {
    kOpusKitApplicationVoIP = 0,
    kOpusKitApplicationAudio,
    kOpusKitApplicationRestrictedLowDelay
};

@interface OKEncoder : OKCodec

@property (nonatomic, readonly) OpusKitApplication application;
@property (nonatomic) NSUInteger bitrate;
@property (nonatomic) AudioStreamBasicDescription inputASBD;

- (BOOL) setupEncoderWithApplication:(OpusKitApplication)application error:(NSError**)error;
- (void) encodeBufferList:(AudioBufferList*)bufferList completionBlock:(void (^)(NSData *data, NSError *error))completionBlock;

+ (OKEncoder*) encoderForASBD:(AudioStreamBasicDescription)asbd application:(OpusKitApplication)application error:(NSError**)error;

@end
