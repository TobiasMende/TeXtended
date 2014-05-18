//
//  CiteInfoViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 23.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CiteInfoViewController : NSViewController

    - (IBAction)showInBibdesk:(id)sender;

    - (BOOL)shouldShowBibDeskButton;

    @property NSString *bibFilePath;
@end
