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

/**
 An implementation of a parser which parses the chktex output, detecting 43 messages of different levels. The level of each message is described by the following property files:
 
 - *Warnings:* ChkTex/ChktexWarningNumbers.plist
 - *Infos:* ChkTex/ChktexInfoNumbers.plist
 - *Debugs:* ChkTex/ChktexDebugNumbers.plist 
 
 **Author:** Tobias Mende
 
 */

@interface ChktexParser : Parser

/**
 Getter which identifies a message type by a given chktex warning number. (see *texdoc chktex* for further information)
 
 @param number the warning number
 
 @return the message type
 */
- (TMTTrackingMessageType) typeForChktexNumber:(NSInteger)number;

/**
 Getter for the further description for a message with a given chktex warning number and a message type 
 (use *texdoc chktex* for further information)
 
 @param number the chktex warning number
 @param type the message type
 
 @return the further information
 */
- (NSString *) messageForChktexNumber: (NSInteger)number ofType:(TMTTrackingMessageType)type;
@end
