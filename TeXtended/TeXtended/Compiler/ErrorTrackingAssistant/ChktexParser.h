//
//  ChktexParser.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parser.h"
#import "TrackingMessage.h"
@interface ChktexParser : Parser

- (TMTTrackingMessageType) typeForChktexNumber:(NSInteger)number;
- (NSString *) messageForChktexNumber: (NSInteger)number ofType:(TMTTrackingMessageType)type;
@end
