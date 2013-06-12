//
//  TexdocPanelController.m
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TexdocPanelController.h"
#import "TexdocController.m"
#import "TexdocViewController.h"
#import "ExtendedTableView.h"

@interface TexdocPanelController ()

@end

@implementation TexdocPanelController

- (id)init {
    self = [super initWithWindowNibName:@"TexdocPanel"];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    
    [self.window makeFirstResponder:self.packageField];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)loadWindow {
    [super loadWindow];
    [self.contentBox setContentView:self.searchPanel];
    [self.window setInitialFirstResponder:self.packageField];
    
}
- (IBAction)startTexdoc:(id)sender {
        TexdocController *tc = [[TexdocController alloc] init];
        self.searching = YES;
        [tc executeTexdocForPackage:self.packageField.stringValue withInfo:nil andHandler:self];
}

- (IBAction)clearSearch:(id)sender {
    [self.packageField setStringValue:@""];
    [self.contentBox setContentView:self.searchPanel];
    [self.window makeFirstResponder:self.packageField];
}

- (void)texdocReadComplete:(NSMutableArray *)texdocArray withPackageName:(NSString *)package andInfo:(NSDictionary *)info {
    
    self.texdocViewController= [[TexdocViewController alloc] init];
    [self.texdocViewController setContent:texdocArray];
    [self.texdocViewController setPackage:package];
    self.searching = NO;
    [self.contentBox setContentView:self.texdocViewController.view];
    [self.texdocViewController setDarkBackgroundMode];
    [self.window makeFirstResponder:self.texdocViewController.listView];
    
}
@end
