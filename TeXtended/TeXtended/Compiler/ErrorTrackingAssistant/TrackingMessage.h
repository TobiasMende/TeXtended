//
//  TrackingMessage.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MessageType) {
    TMTDebugMessage,
    TMTInfoMessage,
    TMTWarningMessage,
    TMTErrorMessage
};


@interface TrackingMessage : NSObject


@property NSString* document;
@property NSUInteger line;
@property NSUInteger column;
@property MessageType type;
@property NSString *title;
@property NSString *info;
@property NSString *furtherInfo;

- (id) initMessage:(MessageType)type inDocument:(NSString *)document inLine:(NSUInteger)line withTitle:(NSString*)title andInfo:(NSString *)info;
+ (id) errorInDocument:(NSString *)document inLine:(NSUInteger)line withTitle:(NSString*)title andInfo:(NSString *)info;
+ (id) warningInDocument:(NSString *)document inLine:(NSUInteger)line withTitle:(NSString*)title andInfo:(NSString *)info;
+ (id) infoInDocument:(NSString *)document inLine:(NSUInteger)line withTitle:(NSString*)title andInfo:(NSString *)info;
+ (id) debugInDocument:(NSString *)document inLine:(NSUInteger)line withTitle:(NSString*)title andInfo:(NSString *)info;
@end
