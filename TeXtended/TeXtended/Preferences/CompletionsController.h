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
@interface CompletionsController : NSObject <NSTableViewDataSource> {

}
@property (assign) CompletionManager *manager;
/** Indexes of the selected rows in the command view */
@property  (strong) NSIndexSet *selectedCommandIndexes;

/** Indexes of selected rows in the environment view */
@property  (strong) NSIndexSet *selectedEnvironmentIndexes;


/** The environment completion view */
@property (assign) IBOutlet NSTableView *environmentView;

/** The command completion view */
@property (assign) IBOutlet NSTableView *commandsView;

/** Removes the selected item of the appropriate table view 
 @param sender the button identified by tag
 */
- (IBAction)removeItem:(id)sender;

/** Adds an item to the appropriate table view 
 @param sender the button identified by tag
 */
- (IBAction)addItem:(id)sender;

/** Resets the environment completions to the set of completions provided with the application bundle 
  @param sender the button identified by tag
 */
- (IBAction)resetEnvironmentCompletions:(id)sender;

/** Resets the command completions to the set of completions provided with the application bundle 
  @param sender the button identified by tag
 */
- (IBAction)resetCommandCompletions:(id)sender;

/**
 Resets the internal completion counter for all command completions so that they are ordered alphabetically.
 @param sender the sender
 */
- (IBAction)resetCommandCompletionRanking:(id)sender;
/**
 Resets the internal completion counter for all environment completions so that they are ordered alphabetically.
 @param sender the sender
 */
- (IBAction)resetEnvironmentCompletionRanking:(id)sender;


+ (CompletionsController *)sharedInstance;
@end
