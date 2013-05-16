//
//  DocumentController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainDocument.h"
@class DocumentModel;
/**
 The DocumentController holds a DocumentModel and the view representations for this model. It only exists if the current document model ist displayed by any views.
 
 
 
 **Author:** Tobias Mende
 
 */
@interface DocumentController : NSObject

- initWithDocument:(DocumentModel *)model;
- initWithDocument:(DocumentModel *)model andMainDocument:(id<MainDocument>) document;
@end
