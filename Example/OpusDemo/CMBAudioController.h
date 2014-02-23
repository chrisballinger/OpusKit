//
//  CMBAudioController.h
//  OpusDemo
//
//  Created by Christopher Ballinger on 2/16/14.
//
//

#import <Foundation/Foundation.h>
#import "EZMicrophone.h"
#import "EZOutput.h"
#import "OpusKit.h"
#import "TPCircularBuffer.h"

@interface CMBAudioController : NSObject <EZMicrophoneDelegate, EZOutputDataSource>

@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) EZOutput *output;
@property (nonatomic, strong) OKEncoder *opusEncoder;
@property (nonatomic, strong) OKDecoder *opusDecoder;
@property (nonatomic) TPCircularBuffer *outputBuffer;

@end
