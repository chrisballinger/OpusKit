//
//  OKUtilities.h
//  OpusKit
//
//  Created by Christopher Ballinger on 2/17/14.
//
//

#import <Foundation/Foundation.h>

@interface OKUtilities : NSObject

+ (NSString*) stringForOpusErrorCode:(int)errorCode;
+ (NSError*) errorForOpusErrorCode:(int)errorCode;
+ (NSError*) errorForOpusErrorCode:(int)errorCode details:(NSString*)details;

@end
