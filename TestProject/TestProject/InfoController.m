//
//  InfoController.m
//  TestProject
//
//  Created by Tobias Mende on 02.04.13.
//
//

#import "InfoController.h"
#import "WebKit/WebView.h"
#import "Webkit/WebFrame.h"

@interface InfoController ()

@end

@implementation InfoController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [infoView setMainFrameURL:@"http://www.apple.com"];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
