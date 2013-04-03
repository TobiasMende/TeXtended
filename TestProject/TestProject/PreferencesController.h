//
//  PreferencesControllerWindowController.h
//  TestProject
//
//  Created by Tobias Mende on 01.04.13.
//
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController <NSWindowDelegate> {
    NSColorWell IBOutlet *backgroundColor;
    NSColorWell IBOutlet *fontColor;
}
- (IBAction)updateDocuments:(id)sender;
- (NSColor*) backgroundColor;
- (NSColor*) textColor;
- (IBAction)windowWillClose:(id)sender;
- (IBAction)resetDefaults:(id)sender;
@end
