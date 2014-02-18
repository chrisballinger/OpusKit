//
//  CMBAudioController.h
//  OpusDemo
//
//  Created by Christopher Ballinger on 2/16/14.
//
//

#import <Foundation/Foundation.h>
#import "EZMicrophone.h"
#import "OpusKit.h"

@interface CMBAudioController : NSObject <EZMicrophoneDelegate>

@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) OKEncoder *opusEncoder;

@end
