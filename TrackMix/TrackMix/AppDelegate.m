//
//  AppDelegate.m
//  TrackMix
//
//  Created by Tobias Mende on 04.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "AppDelegate.h"
#import "Track.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.track = [[Track alloc] init];
    [self updateUserInterface];
}

- (IBAction)mute:(id)sender {
    NSLog(@"mute");
    [self.track setVolume:0.0];
    [self updateUserInterface];
}

- (IBAction)takeFloatValueForVolumeFrom:(id)sender {
    NSLog(@"takeFloatValueForVolumeFrom");
    
}
- (void)updateUserInterface {
    float volume = [self.track volume];
    [self.textField setFloatValue:volume];
    [self.slider setFloatValue:volume];
}
@end
