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
    if (self.document != other.document &&![self.document isEqualToString:other.document]) {
        return NO;
    }
    if (self.info != other.info &&![self.info isEqualToString:other.info]) {
        return NO;
    }
    if (self.title != other.title &&![self.title isEqualToString:other.title]) {
        return NO;
    }
    if (self.furtherInfo != other.furtherInfo && ![self.furtherInfo isEqualToString:other.furtherInfo]) {
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


+ (NSImage *)imageForType:(TMTTrackingMessageType)type {
    switch (type) {
        case TMTErrorMessage:
            return [NSImage imageNamed:@"error.png"];
            break;
        case TMTWarningMessage:
            return [NSImage imageNamed:@"warning.png"];
            break;
        case TMTInfoMessage:
            return [NSImage imageNamed:@"info.png"];
            break;
        case TMTDebugMessage:
            return [NSImage imageNamed:@"info.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

+ (NSColor *)backgroundColorForType:(TMTTrackingMessageType)type {
    switch (type) {
        case TMTErrorMessage:
            return [NSColor colorWithCalibratedRed:0.87f green:0.09f blue:0.00f alpha:0.30f];
            break;
        case TMTWarningMessage:
            return [NSColor colorWithCalibratedRed:1.00f green:0.69f blue:0.00f alpha:0.30f];
            break;
        case TMTInfoMessage:
            return [NSColor colorWithCalibratedRed:0.01f green:0.45f blue:0.78f alpha:0.30f];
            break;
        case TMTDebugMessage:
            return [NSColor colorWithCalibratedRed:0.01f green:0.45f blue:0.78f alpha:0.30f];
            break;
        default:
            return [NSColor whiteColor];
            break;
    }
}

-(NSComparisonResult)compare:(TrackingMessage *)other {
    if (self.type < other.type) {
        return NSOrderedAscending;
    }
    if (self.type > other.type) {
        return NSOrderedDescending;
    }
    if (self.line < other.line) {
        return NSOrderedAscending;
    }
    if (self.line > other.line) {
        return NSOrderedDescending;
    }
    if (self.column < other.column) {
        return NSOrderedAscending;
    }
    if (self.column > other.column) {
        return NSOrderedDescending;
    }
    return [self.title compare:other.title];
}
@end
