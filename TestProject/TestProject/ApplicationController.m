//
//  ApplicationController.m
//  TestProject
//
//  Created by Tobias Mende on 01.04.13.
//
//

#import "ApplicationController.h"
#import "PreferencesController.h"
#import "InfoController.h"
@implementation ApplicationController



- (IBAction)showInfo:(id)sender {
    NSLog(@"Show Info");
    if(!infoController) {
        infoController = [[InfoController alloc] initWithWindowNibName:@"InfoWindow"];
    }
    [infoController showWindow:self];
}

- (IBAction)showPreferences:(id)sender {
    NSLog(@"Show Preferences ...");
    if(!preferencesController) {
        preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
    }
    [preferencesController showWindow:self];
}

+(void)initialize {
    NSMutableDictionary *appDefaults = [[NSMutableDictionary alloc] init];
    [appDefaults setObject:[NSArchiver archivedDataWithRootObject:[NSColor blackColor]] forKey:@"backgroundColor"];
    [appDefaults setObject:[NSArchiver archivedDataWithRootObject:[NSColor greenColor]] forKey:@"textColor"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}
@end
