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

@class DocumentModel;

@interface TrackingMessage : NSObject


@property (weak) DocumentModel* document;
@property NSUInteger lineNumber;
@property MessageType type;
@property NSString *title;
@property NSString *info;
@property NSString *description;

- (id) initMessage:(MessageType)type inDocument:(DocumentModel *)document inLine:(NSUInteger)line withTitle:(NSString*)title andInfo:(NSString *)info;
+ (id) errorInDocument:(DocumentModel *)document inLine:(NSUInteger)line withTitle:(NSString*)title andInfo:(NSString *)info;
+ (id) warningInDocument:(DocumentModel *)document inLine:(NSUInteger)line withTitle:(NSString*)title andInfo:(NSString *)info;
+ (id) infoInDocument:(DocumentModel *)document inLine:(NSUInteger)line withTitle:(NSString*)title andInfo:(NSString *)info;
+ (id) debugInDocument:(DocumentModel *)document inLine:(NSUInteger)line withTitle:(NSString*)title andInfo:(NSString *)info;
@end
