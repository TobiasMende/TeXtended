//
//  TemplatePlaceholderController.h
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TMTQuickLookView;
@interface TemplatePlaceholderController : NSCollectionViewItem
@property (strong) IBOutlet TMTQuickLookView *quickLook;

@end
