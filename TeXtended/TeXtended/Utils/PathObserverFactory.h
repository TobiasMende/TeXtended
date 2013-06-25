//
//  PathObserverFactory.h
//  TeXtended
//
//  Created by Tobias Mende on 06.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The path observer is an object which uses an FSEventStream for monitoring changes to a given directory.
 
 Instances of this class are currently able to notifiy observers for changes in the given directory of the following type:
 
    - item renaming
    - item creating
    - item removing
 
 @warning *Important:* Instances of this class should never be generated directly. Use the [PathObserverFactory pathObserverForPath:] method instead.
 
 
 **Author:** Tobias Mende
 
 */
@interface PathObserver : NSObject {
    /** The lock ensures, that the `observers` array stays in sync with the actions array at every time */
    NSLock *observersLock;
    
    /** An array containing the `observers` interestes in changes of the directory in `filePath` */
    NSMutableArray *observers;
    
    /** An array of selectors performed on the observers */
    NSMutableArray *actions;
    
    /** The path observed by this PathObserver */
    NSString *filePath;
    
    /** The current stream */
    FSEventStreamRef stream;
    
    /** The identifier of the last file event */
    NSNumber* lastEventId;
}

/**
 Initializes a new PathObserver for a given path
 
 @param path the absolute path to observe
 
 @return the observer
 */
- (id)initWithPath:(NSString *)path;

/** Notifies the observer about changes in the directory */
- (void) pathWasModified;

/**
 Method for adding an observer on which the given selector is performed on events
 
 @param observer the change observer
 @param action the action to perform on the observer in case of changes
 
 */
- (void) addObserver:(id)observer withSelector:(SEL)action;

/**
 Method for removing an observer from the PathObserver.
 This method causes the PathObserverFactory to free the current PathObserver if the last observer is removed.
 
 @param observer the observer to remove
 */
- (void) removeObserver:(id)observer;
@end

/**
 The PathObserverFactory uses the *Factory Pattern* to manage all PathObserver instances. This reduces the amount of FSEvent usages because multiple observers of the same path are able to use the same PathObserver.
 
 **Author:** Tobias Mende
 
 */
@interface PathObserverFactory : NSObject {
    
}

/**
 Method for getting an appropriate PathObserver instance for a given path.
 
 This method returns an existing instance, if one was created for the given path before. Otherwise a new instance is automatically created and stored for further used.
 
 @param path the path to observe.
 
 @return a PathObserver observing changes in the given path.
 */
+ (PathObserver *)pathObserverForPath:(NSString*)path;

/** Method for removing a PathObserver instance from the factorys dictionary.
 
 @warning *Important:* you should not call this method directly. It is called by the PathObserver itself, when neccesary.
 
 @param path the path to remove the observer from
 
 */
+ (void) removePathObserverForPath:(NSString *)path;

/** Method for removing an observer from all stored PathObserver instances.
 
 This method is very usefull if an observer should be deallocated because the PathObserverFactory does all the work for the observer
 
 @param observer the observer to remove from all PathObserver instances
 */
+ (void) removeObserver:(id)observer;

@end


