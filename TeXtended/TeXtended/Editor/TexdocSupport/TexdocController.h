//
//  TexdocController.h
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TexdocHandlerProtocol.h"

/**
 The TexdocController handles the execution of a *texdoc* task and parses its output.
 
 **Author:** Tobias Mende
 
 */
@interface TexdocController : NSObject
    {
        NSTask *task;
    }

/**
 Method for starting a texdoc terminal task for getting a list of entries for the given package name
 
 @param name the package name to search for
 @param info information that should be passed through the extraction process.
 @param handler an implementation TexdocHandlerProtocol where to call the callback action [TexdocHandlerProtocol texdocReadComplete:withPackageName:andInfo:]
 */
    - (void)executeTexdocForPackage:(NSString *)name withInfo:(NSDictionary *)info andHandler:(id <TexdocHandlerProtocol>)handler;
@end
