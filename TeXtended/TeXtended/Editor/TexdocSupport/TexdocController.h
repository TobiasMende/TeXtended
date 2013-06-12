//
//  TexdocController.h
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TexdocHandlerProtocol.h"

@interface TexdocController : NSObject
- (void) executeTexdocForPackage:(NSString*)name withInfo:(NSDictionary*)info andHandler:(id<TexdocHandlerProtocol>) handler;
@end
