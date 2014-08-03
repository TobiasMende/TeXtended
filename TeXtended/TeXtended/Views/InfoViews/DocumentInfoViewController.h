//
//  DocumentInfoViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "ModelInfoViewController.h"
@class DocumentModel, TMTQuickLookView;

@interface DocumentInfoViewController : NSViewController <ModelInfoViewController>

    @property DocumentModel *model;

    @property (strong, nonatomic) IBOutlet TMTQuickLookView *quickLook;

    - (id <QLPreviewItem>)previewItem;

    - (BOOL)pdfExists;
@end
