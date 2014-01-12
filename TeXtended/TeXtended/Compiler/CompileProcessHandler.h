//
//  CompileProcessHandler.h
//  TeXtended
//
//  Created by Tobias Mende on 05.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MainDocument, DocumentModel, TextViewController;
@protocol CompileProcessHandler <NSObject>
- (MainDocument *)mainDocument;
- (DocumentModel *) model;
- (void) compile:(CompileMode)mode;
- (void) liveCompile:(id)sender;
- (void)documentHasChangedAction;
- (TextViewController *)textViewController;
- (void)abort;
@end
