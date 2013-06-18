//
//  TrackingMessage.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TrackingMessage.h"

@implementation TrackingMessage

+ (id)errorInDocument:(DocumentModel *)document inLine:(NSUInteger)line withTitle:(NSString *)title andInfo:(NSString *)info {
    return [[TrackingMessage alloc] initMessage:TMTErrorMessage inDocument:document inLine:line withTitle:title andInfo:info];
}

+(id)warningInDocument:(DocumentModel *)document inLine:(NSUInteger)line withTitle:(NSString *)title andInfo:(NSString *)info {
    return [[TrackingMessage alloc] initMessage:TMTWarningMessage inDocument:document inLine:line withTitle:title andInfo:info];
}

+ (id)infoInDocument:(DocumentModel *)document inLine:(NSUInteger)line withTitle:(NSString *)title andInfo:(NSString *)info {
    return [[TrackingMessage alloc] initMessage:TMTInfoMessage inDocument:document inLine:line withTitle:title andInfo:info];
}

+ (id)debugInDocument:(DocumentModel *)document inLine:(NSUInteger)line withTitle:(NSString *)title andInfo:(NSString *)info {
    return [[TrackingMessage alloc] initMessage:TMTDebugMessage inDocument:document inLine:line withTitle:title andInfo:info];
}

- (id)initMessage:(MessageType)type inDocument:(DocumentModel *)document inLine:(NSUInteger)line withTitle:(NSString *)title andInfo:(NSString *)info {
    self = [super init];
    if (self) {
        _type = type;
        _document = document;
        _lineNumber = line;
        _title = title;
        _info = info;
    }
    return self;
}

@end
