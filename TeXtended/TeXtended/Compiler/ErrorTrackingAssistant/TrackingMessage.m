//
//  TrackingMessage.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TrackingMessage.h"

@implementation TrackingMessage

+ (id)errorInDocument:(NSString *)document inLine:(NSUInteger)line withTitle:(NSString *)title andInfo:(NSString *)info {
    return [[TrackingMessage alloc] initMessage:TMTErrorMessage inDocument:document inLine:line withTitle:title andInfo:info];
}

+(id)warningInDocument:(NSString *)document inLine:(NSUInteger)line withTitle:(NSString *)title andInfo:(NSString *)info {
    return [[TrackingMessage alloc] initMessage:TMTWarningMessage inDocument:document inLine:line withTitle:title andInfo:info];
}

+ (id)infoInDocument:(NSString *)document inLine:(NSUInteger)line withTitle:(NSString *)title andInfo:(NSString *)info {
    return [[TrackingMessage alloc] initMessage:TMTInfoMessage inDocument:document inLine:line withTitle:title andInfo:info];
}

+ (id)debugInDocument:(NSString *)document inLine:(NSUInteger)line withTitle:(NSString *)title andInfo:(NSString *)info {
    return [[TrackingMessage alloc] initMessage:TMTDebugMessage inDocument:document inLine:line withTitle:title andInfo:info];
}

- (id)initMessage:(TMTTrackingMessageType)type inDocument:(NSString *)document inLine:(NSUInteger)line withTitle:(NSString *)title andInfo:(NSString *)info {
    self = [super init];
    if (self) {
        _type = type;
        _document = document;
        _line = line;
        _title = title;
        _info = info;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"Message(%i) for %@ in %li:\n", self.type,self.document,self.line];
    [string appendFormat:@"\t *** %@ ***\n", self.title];
    [string appendFormat:@"%@", self.info];
    return string;
}

@end
