//
//  OKUtilities.m
//  OpusKit
//
//  Created by Christopher Ballinger on 2/17/14.
//
//

#import "OKUtilities.h"
#import "opus_defines.h"

static NSString * const kOpusKitErrorDomain = @"org.opus-codec.opus";

@implementation OKUtilities

+ (NSError*) errorForOpusErrorCode:(int)errorCode {
    return [self errorForOpusErrorCode:errorCode details:nil];
}

+ (NSError*) errorForOpusErrorCode:(int)errorCode details:(NSString *)details {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[self stringForOpusErrorCode:errorCode] forKey:NSLocalizedDescriptionKey];
    if (details) {
        [userInfo setObject:details forKey:NSLocalizedFailureReasonErrorKey];
    }
    return [NSError errorWithDomain:kOpusKitErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSString*) stringForOpusErrorCode:(int)errorCode {
    switch (errorCode) {
        case OPUS_BAD_ARG:
            return @"One or more invalid/out of range arguments";
        case OPUS_BUFFER_TOO_SMALL:
            return @"The mode struct passed is invalid";
        case OPUS_INTERNAL_ERROR:
            return @"The compressed data passed is corrupted";
        case OPUS_INVALID_PACKET:
            return @"Invalid/unsupported request number";
        case OPUS_INVALID_STATE:
            return @"An encoder or decoder structure is invalid or already freed.";
        case OPUS_UNIMPLEMENTED:
            return @"Invalid/unsupported request number.";
        case OPUS_ALLOC_FAIL:
            return @"Memory allocation has failed.";
        default:
            return nil;
            break;
    }
}

@end
