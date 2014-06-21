//
//  TexdocHandlerProtocol.h
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 The TexdocHandlerProtocol must be implemented by any class dealing the the TexdocController.
 
 **Author:** Tobias Mende
 
 */
@protocol TexdocHandlerProtocol <NSObject>

/**
 Callback method for the texdoc task is called after the texdoc command has finished returning a list of possible documents.
 
 @param notification A `NSFileHandleReadToEndOfFileCompletionNotification` after the command output is available as data.
 @param package The package name which was clicked
 @param rect a rect for specifing the position where to show the documents
 */
    - (void)texdocReadComplete:(NSMutableArray *)texdocArray withPackageName:(NSString *)package andInfo:(NSDictionary *)info;
@end
