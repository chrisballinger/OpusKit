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

- (void) dealloc {
    if (_outputBuffer) {
        TPCircularBufferCleanup(_outputBuffer);
        free(_outputBuffer);
    }
}

- (id) init {
    if (self = [super init]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                [self setupMicrophone];
                [self setupOutput];
            } else {
                NSLog(@"Error: Need permission to record audio");
            }
        }];
        
    }
    return self;
}

- (void) setupOutput {
    self.output = [EZOutput outputWithDataSource:self];
    self.opusDecoder = [[OKDecoder alloc] initWithSampleRate:self.opusEncoder.sampleRate numberOfChannels:self.opusEncoder.numberOfChannels];
    NSError *error = nil;
    if (![self.opusDecoder setupDecoderWithError:&error]) {
        NSLog(@"Error setting up opus decoder: %@", error);
    }
    self.outputBuffer = malloc(sizeof(TPCircularBuffer));
    BOOL success = TPCircularBufferInit(_outputBuffer, 100000);
    if (!success) {
        NSLog(@"Error allocating output buffer");
    }
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
        NSLog(@"Error setting up opus encoder: %@", error);
    }
}

- (void) microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
    [EZAudio printASBD:audioStreamBasicDescription];
}

- (void) decodePacket:(NSData*)packetData {
    [self.opusDecoder decodePacket:packetData completionBlock:^(NSData *pcmData, NSUInteger numDecodedSamples, NSError *error) {
        if (error) {
            NSLog(@"Error decoding packet: %@", error);
            return;
        }
        BOOL success = TPCircularBufferProduceBytes(_outputBuffer, pcmData.bytes, pcmData.length);
        if (!success) {
            NSLog(@"Error copying output pcm into buffer, insufficient space");
        }
    }];
}

- (void) microphone:(EZMicrophone *)microphone hasBufferList:(AudioBufferList *)bufferList withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
    [self.opusEncoder encodeBufferList:bufferList completionBlock:^(NSData *data, NSError *error) {
        if (!self.output.isPlaying) {
            [self.output startPlayback];
        }
        if (data) {
            NSLog(@"opus data length: %d", data.length);
            [self decodePacket:data];
        } else {
            NSLog(@"Error encoding frame to opus: %@", error);
        }
    }];
}

- (TPCircularBuffer*) outputShouldUseCircularBuffer:(EZOutput *)output {
    return _outputBuffer;
}

@end
