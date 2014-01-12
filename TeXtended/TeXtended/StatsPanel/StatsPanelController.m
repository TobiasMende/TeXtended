//
//  StatsPanelController.m
//  TeXtended
//
//  Created by Tobias Hecht on 05.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "StatsPanelController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "Constants.h"

@interface StatsPanelController ()

@end

@implementation StatsPanelController

- (id)init {
    self = [super initWithWindowNibName:@"StatsPanel"];
    
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)showStatistics:(NSString*)content
{
    /*self.panelTitle = [NSLocalizedString(@"Statistics", @"Statistics") stringByAppendingString:[NSString stringWithFormat:@" - %@",[filename lastPathComponent]]];
    NSTask *task = [[NSTask alloc]init];
    NSPipe *outPipe = [NSPipe pipe];
    task.standardOutput = outPipe;
    task.launchPath = [[[NSUserDefaults standardUserDefaults] valueForKey:TMT_PATH_TO_TEXBIN] stringByAppendingPathComponent:@"texcount"];
    task.arguments = @[@"-inc",@"-brief", @"-q", @"-total", [NSString stringWithFormat:@"\"%@\"",filename]];
    task.currentDirectoryPath = [filename stringByDeletingLastPathComponent];
    [task launch];
    [task waitUntilExit];
    NSString *output = [[NSString alloc] initWithData:[[outPipe fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    [self parseOutputString:output];
    [self showWindow:self];*/
}

/*-(void)parseOutputString:(NSString*)output
{
    // String has Format "TEXTWORDS+HEADERWORDS+CAPTIONWORDS (HEADERNUMBER/FLOATNUMBER/MATHINLINENUMBER/DISPLAYEDMATHNUMBER) TOTAL COUNT"
    NSArray *stringComponents = [output componentsSeparatedByString:@"+"];
    self.wordsInText = stringComponents[0];
    self.wordsInHeader = stringComponents[1];
    self.wordsInCaption = [stringComponents[2] componentsSeparatedByString:@" "][0];
}*/

@end
