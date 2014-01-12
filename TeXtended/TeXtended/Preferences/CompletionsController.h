//
//  CompletionsController.h
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CompletionManager;
/**
 The CompletionsController handles loading and saving of auto completions and the displaying and editing of them in the preferences window.

 For a better performance when completing, completions are stored in a NSMutableDictionary. Therefor a NSMutableArray is used to sync the dictionary with the table view. This provides a sorted view.
 
 **Author:** Tobias Mende
 
 
 @warning *Important:* Due to the fact that this class deals with files in the application support folder. There can't be more than one instance of the CompletionsController. To ensure this fact, it's designed as singleton. Therefor calling [CompletionsController init] doesn't create a new instance if one exists.
 */
@interface CompletionsController : NSObject<NSTableViewDelegate> {

}
@property (assign) CompletionManager *manager;



/** The environment completion view */
@property (assign) IBOutlet NSTableView *environmentView;

/** The command completion view */
@property (assign) IBOutlet NSTableView *commandsView;

/** The drop completion view */
@property (assign) IBOutlet NSTableView *dropView;

@property (assign) IBOutlet NSArrayController *commandsController;


+ (CompletionsController *)sharedCompletionsController;

@end
