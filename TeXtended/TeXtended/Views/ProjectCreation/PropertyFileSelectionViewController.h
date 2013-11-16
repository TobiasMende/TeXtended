//
//  PropertyFileSelectionViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PropertyFileSelectionViewController : NSViewController

@property (strong) IBOutlet NSString* filePath;
- (IBAction)select:(id)sender;

@end
