//
//  OpusEncoder.m
//  OpusKit
//
//  Created by Christopher Ballinger on 2/17/14.
//
//

#import "OKEncoder.h"
#import "opus.h"
#import "OKUtilities.h"
#import "TPCircularBuffer+AudioBufferList.h"

static const int kNumberOfSamplesPerChannel = 2880;

@interface OKEncoder()
@property (nonatomic) OpusEncoder *encoder;
@property (nonatomic) uint8_t *encoderOutputBuffer;
@property (nonatomic) NSUInteger encoderBufferLength;
@property (nonatomic) TPCircularBuffer *circularBuffer;
@end

@implementation OKEncoder

- (void) dealloc {
    if (_encoder) {
        opus_encoder_destroy(_encoder);
    }
    if (_encoderOutputBuffer) {
        free(_encoderOutputBuffer);
    }
    if (self.circularBuffer) {
        TPCircularBufferCleanup(_circularBuffer);
        free(_circularBuffer);
    }
}

- (void) setBitrate:(NSUInteger)bitrate {
    if (!_encoder) {
        return;
    }
    _bitrate = bitrate;
    dispatch_async(self.processingQueue, ^{
        opus_encoder_ctl(_encoder, OPUS_SET_BITRATE(bitrate));
    });
}

- (int) opusApplicationForOpusKitApplication:(OpusKitApplication)application {
    switch (application) {
        case kOpusKitApplicationVoIP:
            return OPUS_APPLICATION_VOIP;
        case kOpusKitApplicationAudio:
            return OPUS_APPLICATION_AUDIO;
        case kOpusKitApplicationRestrictedLowDelay:
            return OPUS_APPLICATION_RESTRICTED_LOWDELAY;
        default:
            return -1;
            break;
    }
}

- (BOOL) setupEncoderWithApplication:(OpusKitApplication)application error:(NSError *__autoreleasing *)error {
    if (self.encoder) {
        return YES;
    }
    int app = [self opusApplicationForOpusKitApplication:application];
    int opusError = OPUS_OK;
    self.encoder = opus_encoder_create(self.sampleRate, self.numberOfChannels, app, &opusError);
    if (opusError != OPUS_OK) {
        *error = [OKUtilities errorForOpusErrorCode:opusError];
        return NO;
    }
    
    self.encoderBufferLength = 4000;
    self.encoderOutputBuffer = malloc(_encoderBufferLength * sizeof(uint8_t));
    self.circularBuffer = malloc(sizeof(TPCircularBuffer));
    BOOL success = TPCircularBufferInit(_circularBuffer, kNumberOfSamplesPerChannel * 10);
    if (!success) {
        NSLog(@"Error allocating circular buffer");
        return NO;
    }
    
    return YES;
}

+ (OKEncoder*) encoderForASBD:(AudioStreamBasicDescription)absd application:(OpusKitApplication)application error:(NSError *__autoreleasing *)error {
    OKEncoder *encoder = [[OKEncoder alloc] initWithSampleRate:absd.mSampleRate numberOfChannels:absd.mChannelsPerFrame];
    encoder.inputASBD = absd;
    BOOL success = [encoder setupEncoderWithApplication:application error:error];
    if (success) {
        return encoder;
    }
    return nil;
}

- (void) encodeBufferList:(AudioBufferList *)bufferList completionBlock:(void (^)(NSData *, NSError *))completionBlock {
    if (!completionBlock) {
        return;
    }
    dispatch_async(self.processingQueue, ^{
        BOOL success = TPCircularBufferCopyAudioBufferList(_circularBuffer, bufferList, NULL, kTPCircularBufferCopyAll, &_inputASBD);
        if (!success) {
            NSLog(@"insufficient space in circular buffer!");
        }
        
        int32_t availableBytes = 0;
        opus_int16 *data = (opus_int16*)TPCircularBufferTail(_circularBuffer, &availableBytes);
        int availableSamples = availableBytes / _inputASBD.mBytesPerFrame;
        if (availableSamples < kNumberOfSamplesPerChannel) {
            return;
        }
        int returnValue = opus_encode(_encoder, data, kNumberOfSamplesPerChannel, _encoderOutputBuffer, _encoderBufferLength);
        TPCircularBufferConsume(_circularBuffer, kNumberOfSamplesPerChannel * _inputASBD.mBytesPerFrame);
        if (returnValue < 0) {
            NSError *error = [OKUtilities errorForOpusErrorCode:returnValue];
            completionBlock(nil, error);
            return;
        }
        NSData *outputData = [NSData dataWithBytes:self.encoderOutputBuffer length:returnValue];
        completionBlock(outputData, nil);
    });
}



@end
