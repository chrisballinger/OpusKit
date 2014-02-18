//
//  CMBAudioController.m
//  OpusDemo
//
//  Created by Christopher Ballinger on 2/16/14.
//
//

#import "CMBAudioController.h"
#import <AVFoundation/AVFoundation.h>
#import "EZAudio.h"

@implementation CMBAudioController


- (instancetype) init {
    if (self = [super init]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                [self setupMicrophone];
            } else {
                NSLog(@"Error: Need permission to record audio");
            }
        }];
        
    }
    return self;
}

- (void) setupMicrophone {
    NSError *error = nil;
    int preferredSampleRate = kOpusKitSampleRate_48000;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setPreferredSampleRate:preferredSampleRate error:&error];
    if (error) {
        NSLog(@"Error setting preferred sample rate to %d: %@", preferredSampleRate, error);
    }
    
    self.microphone = [[EZMicrophone alloc] initWithMicrophoneDelegate:self];
    AudioStreamBasicDescription absd = [self.microphone audioStreamBasicDescription];
    [self setupOpusFromABSD:absd];
    [self.microphone startFetchingAudio];
}

- (void) setupOpusFromABSD:(AudioStreamBasicDescription)absd {
    NSError *error = nil;
    self.opusEncoder = [OKEncoder encoderForASBD:absd application:kOpusKitApplicationVoIP error:&error];
    if (error) {
        NSLog(@"Error setting up opus: %@", error);
    }
}

- (void) microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
    [EZAudio printASBD:audioStreamBasicDescription];
}

- (void) microphone:(EZMicrophone *)microphone hasBufferList:(AudioBufferList *)bufferList withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
    [self.opusEncoder encodeBufferList:bufferList completionBlock:^(NSData *data, NSError *error) {
        if (data) {
            NSLog(@"opus data length: %d", data.length);
        } else {
            NSLog(@"Error encoding frame to opus: %@", error);
        }
    }];
}

@end
