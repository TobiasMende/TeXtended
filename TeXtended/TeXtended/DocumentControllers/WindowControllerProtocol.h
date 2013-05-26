//
//  WindowControllerProtocol.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentController;
@protocol WindowControllerProtocol <NSObject>

- (void) setDocumentController:(DocumentController *) dc;
- (void) clearAllDocumentViews;
@optional
- (void) addTextView:(NSView *) view;
- (void) addPDFViewsView:(NSView *) view;
- (void) addConsoleViewsView:(NSView *) view;
- (void) addOutlineView:(NSView *) view;


@end
