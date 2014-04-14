//
//  OpusDecoder.m
//  OpusKit
//
//  Created by Christopher Ballinger on 2/17/14.
//
//

#import "OKDecoder.h"
#import "opus.h"
#import "OKUtilities.h"
#import <AVFoundation/AVFoundation.h>

static const int kNumberOfSamplesPerChannel = 5760;

@interface OKDecoder()
@property (nonatomic) OpusDecoder *decoder;
@property (nonatomic) opus_int16 *outputBuffer;
@property (nonatomic) NSUInteger decoderBufferLength;
@end

@implementation OKDecoder

- (void) dealloc {
    if (_decoder) {
        opus_decoder_destroy(_decoder);
    }
    if (_outputBuffer) {
        free(_outputBuffer);
    }
}

- (id) initWithSampleRate:(OpusKitSampleRate)sampleRate numberOfChannels:(OpusKitChannels)channels {
    if (self = [super initWithSampleRate:sampleRate numberOfChannels:channels]) {
        _forwardErrorCorrection = NO;
        _decoderBufferLength = kNumberOfSamplesPerChannel*self.numberOfChannels*sizeof(opus_int16);
        self.outputBuffer = malloc(_decoderBufferLength);
    }
    return self;
}


- (BOOL) setupDecoderWithError:(NSError *__autoreleasing *)error {
    if (self.decoder) {
        return YES;
    }
    int opusError = OPUS_OK;
    self.decoder = opus_decoder_create(self.sampleRate, self.numberOfChannels, &opusError);
    if (opusError != OPUS_OK) {
        *error = [OKUtilities errorForOpusErrorCode:opusError];
        return NO;
    }
    
    return YES;
}

+ (OKDecoder*) decoderForASBD:(AudioStreamBasicDescription)absd error:(NSError *__autoreleasing *)error {
    OKDecoder *decoder = [[OKDecoder alloc] initWithSampleRate:absd.mSampleRate numberOfChannels:absd.mChannelsPerFrame];
    BOOL success = [decoder setupDecoderWithError:error];
    if (success) {
        return decoder;
    }
    return nil;
}

- (void) decodePacket:(NSData*)packetData completionBlock:(void (^)(NSData *pcmData, NSUInteger numDecodedSamples, NSError *error))completionBlock {
    if (!completionBlock) {
        return;
    }
    dispatch_async(self.processingQueue, ^{
        int32_t decodedSamples = 0;
        
        int returnValue = opus_decode(_decoder, [packetData bytes], packetData.length, _outputBuffer, kNumberOfSamplesPerChannel, _forwardErrorCorrection);
        if (returnValue < 0) {
            NSError *error = [OKUtilities errorForOpusErrorCode:returnValue];
            completionBlock(nil, 0, error);
            return;
        }
        decodedSamples = returnValue;
        
        NSUInteger length = decodedSamples * sizeof(opus_int16) * self.numberOfChannels;
        NSData *pcmData = [NSData dataWithBytes:_outputBuffer length:length];
        completionBlock(pcmData, decodedSamples, nil);
    });
}

@end