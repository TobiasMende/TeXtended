//
//  DocumentInfoViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "DocumentInfoViewController.h"
#import "DocumentModel.h"
#import "TMTQuickLookView.h"

@interface DocumentInfoViewController ()

@end

@implementation DocumentInfoViewController

    - (id)init
    {
        self = [super initWithNibName:@"DocumentInfoView" bundle:nil];
        return self;
    }

    - (void)awakeFromNib
    {
        [super awakeFromNib];
        self.quickLook.shouldCloseWithWindow = NO;
        [self.quickLook bind:@"previewItem" toObject:self withKeyPath:@"previewItem" options:nil];
    }

    + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
        NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
        if ([key isEqualToString:@"previewItem"] || [key isEqualToString:@"pdfExists"]) {
            keys = [keys setByAddingObject:@"model.pdfPath"];
        }
        return keys;
    }

    - (id <QLPreviewItem>)previewItem
    {
        return [NSURL fileURLWithPath:self.model.pdfPath];
    }

    - (BOOL)pdfExists
    {
        return [[NSFileManager defaultManager] fileExistsAtPath:self.model.pdfPath];
    }

-(void)dealloc {
    [self.quickLook close];
    
}

@end
