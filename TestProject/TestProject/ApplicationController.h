//
//  ApplicationController.h
//  TestProject
//
//  Created by Tobias Mende on 01.04.13.
//
//

#import <Foundation/Foundation.h>
@class PreferencesController, InfoController;
@interface ApplicationController : NSObject {
    PreferencesController *preferencesController;
    InfoController *infoController;


}
- (IBAction)showInfo:(id)sender;
- (IBAction)showPreferences:(id)sender;

@end
