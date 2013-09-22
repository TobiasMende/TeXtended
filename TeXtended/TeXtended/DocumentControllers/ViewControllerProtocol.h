//
//  ViewControllerProtocol.h
//  TeXtended
//
//  Created by Tobias Mende on 22.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentController;

@protocol ViewControllerProtocol <NSObject>


@optional
- (id) initWithDocumentController:(DocumentController*) dc;
- (void)documentModelDidChange;
- (void)documentModelHasChangedAction:(DocumentController*)dc;
- (void)documentHasChangedAction;
- (void)breakUndoCoalescing;

@end
