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
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@ for %@ in %li:\n", [TrackingMessage typeToString:self.type],self.document,self.line];
    [string appendFormat:@"\t *** %@ ***\n", self.title];
    [string appendFormat:@"%@", self.info];
    return string;
}

+ (id)typeToString:(TMTTrackingMessageType)type {
    switch (type) {
        case TMTErrorMessage:
            return @"Error";
            break;
        case TMTWarningMessage:
            return @"Warning";
            break;
        case TMTInfoMessage:
            return @"Info";
            break;
        case TMTDebugMessage:
            return @"Debug";
            break;
            
        default:
            return @"Unknown";
            break;
    }
}


- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + self.line;
    result = prime * result + self.column;
    result = prime * result + self.type;
    result = prime * result + self.document.hash;
    result = prime * result + self.title.hash;
    result = prime * result + self.info.hash;
    result = prime * result + self.furtherInfo.hash;
    return result;
}

- (BOOL)isEqual:(id)obj {
    if (obj == self) {
        return YES;
    }
    if (!obj || ![obj isKindOfClass:self.class]) {
        return NO;
    }
    TrackingMessage *other = obj;
    if (![self.document isEqualToString:other.document]) {
        return NO;
    }
    if (![self.info isEqualToString:other.info]) {
        return NO;
    }
    if (![self.title isEqualToString:other.title]) {
        return NO;
    }
    if (![self.furtherInfo isEqualToString:other.furtherInfo]) {
        return NO;
    }
    if (self.line != other.line) {
        return NO;
    }
    if (self.column != other.column) {
        return NO;
    }
    if (self.type != other.type) {
        return NO;
    }
    return YES;
}


@end
