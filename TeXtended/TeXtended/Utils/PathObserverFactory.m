//
//  PathObserverFactory.m
//  TeXtended
//
//  Created by Tobias Mende on 06.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PathObserverFactory.h"
#import "PathFactory.h"

static NSMutableDictionary *PATH_OBSERVER_DICTIONARY;
typedef struct FlagMap {
    int bitflag;
    const char *description;
} FlagMap;
static FlagMap DEBUG_FLAGS[] = {
    { kFSEventStreamEventFlagMustScanSubDirs, "must scan subdirs"     },
    { kFSEventStreamEventFlagUserDropped,     "user dropped events"   },
    { kFSEventStreamEventFlagKernelDropped,   "kernel dropped events" },
    { kFSEventStreamEventFlagEventIdsWrapped, "event ids wrapped"     },
    { kFSEventStreamEventFlagHistoryDone,     "history playback done" },
    { kFSEventStreamEventFlagRootChanged,     "root changed"          },
    { kFSEventStreamEventFlagMount,           "mounted"               },
    { kFSEventStreamEventFlagUnmount,         "unmounted"             },
    { kFSEventStreamEventFlagItemCreated,         "item created"      },
    { kFSEventStreamEventFlagItemRenamed,      "item renamed"       },
    { kFSEventStreamEventFlagItemRemoved,      "item removed"       }
};

static FlagMap USED_FLAGS[] = {
    { kFSEventStreamEventFlagItemCreated,         "item created"      },
    { kFSEventStreamEventFlagItemRenamed,      "item renamed"       },
    { kFSEventStreamEventFlagItemRemoved,      "item removed"       }
};

@implementation PathObserverFactory

+ (void)initialize {
    if (self == [PathObserverFactory class]) {
        PATH_OBSERVER_DICTIONARY = [NSMutableDictionary new];
    }
}


+ (PathObserver *)pathObserverForPath:(NSString *)path {
    PathObserver *observer = [PATH_OBSERVER_DICTIONARY objectForKey:path];
    if (!observer) {
        observer = [[PathObserver alloc] initWithPath:path];
        [PATH_OBSERVER_DICTIONARY setObject:observer forKey:path];
        NSLog(@"Creating pathObserver: %@ (%@)", observer, path);
    }
return observer;
}

+ (void)removePathObserverForPath:(NSString *)path {
    [PATH_OBSERVER_DICTIONARY removeObjectForKey:path];
    NSLog(@"Removing pathObserver (%@)", path);
}

+ (void)removeObserver:(id)observer {
    for (NSString *key in PATH_OBSERVER_DICTIONARY) {
        [[PATH_OBSERVER_DICTIONARY objectForKey:key] removeObserver:observer];
    }
}

@end


@interface PathObserver ()
/** Method for initializing the event stream */
- (void) initializeEventStream;
@end

@implementation PathObserver

- (id)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        filePath = path;
        observersLock = [NSLock new];
        observers = [NSMutableArray new];
        actions = [NSMutableArray new];
        [self initializeEventStream];
    }
    return self;
}

- (void)initializeEventStream {
    NSArray *pathsToWatch = [NSArray arrayWithObject:filePath];
    void *appPointer = (__bridge void *)self;
    FSEventStreamContext context = {0, appPointer, NULL, NULL, NULL};
    NSTimeInterval latency = 3.0;
    stream = FSEventStreamCreate(NULL,
                                 &fsevents_callback,
                                 &context,
                                 (__bridge CFArrayRef) pathsToWatch,
                                 [lastEventId unsignedLongLongValue],
                                 (CFAbsoluteTime) latency,
                                 kFSEventStreamCreateFlagUseCFTypes
                                 );
    
    FSEventStreamScheduleWithRunLoop(stream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
}


- (void)addObserver:(id)observer withSelector:(SEL)action {
    [observersLock lock];
    [observers addObject:[NSValue valueWithNonretainedObject:observer]];
    [actions addObject:NSStringFromSelector(action)];
    [observersLock unlock];
}

- (void)removeObserver:(id)observer {
    [observersLock lock];
    NSUInteger index = [observers indexOfObject:[NSValue valueWithNonretainedObject:observer]];
    if (index != NSNotFound) {
        [observers removeObjectAtIndex:index];
        [actions removeObjectAtIndex:index];
    }
    
    if (observers.count == 0) {
        [PathObserverFactory removePathObserverForPath:filePath];
    }
    [observersLock unlock];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
-(void)pathWasModified {
    [observersLock lock];
    for (NSUInteger i = 0; i < observers.count; i++) {
        SEL action = NSSelectorFromString([actions objectAtIndex:i]);
        [[[observers objectAtIndex:i] nonretainedObjectValue] performSelector:action];
    }
    [observersLock unlock];
}
#pragma clang diagnostic pop


/**
 Callback handler for the FSEventStream
 */
void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[])
{
    BOOL shouldHandleEvent = NO;
    
    for(int i=0; i < numEvents; i++){
        FSEventStreamEventFlags flags = eventFlags[i];
        // Display all of the set flags.
        FlagMap *scan = USED_FLAGS;
        FlagMap *stop = scan + sizeof(USED_FLAGS) / sizeof(*USED_FLAGS);
        while (scan < stop) {
            if (flags & scan->bitflag) {
                shouldHandleEvent = YES;
                //printf ("    %s\n", scan->description);
                goto after_loop;
            }
            scan++;
        }
    }
after_loop:
    if (shouldHandleEvent) {
        PathObserver *po = (__bridge PathObserver *)userData;
        [po pathWasModified];
    }
    //fsevents_debug(eventFlags, numEvents);
    
    
}

void fsevents_debug(const FSEventStreamEventFlags eventFlags[], size_t numEvents) {
    for(int i=0; i < numEvents; i++){
        FSEventStreamEventFlags flags = eventFlags[i];
        // Display all of the set flags.
        FlagMap *scan = DEBUG_FLAGS;
        FlagMap *stop = scan + sizeof(DEBUG_FLAGS) / sizeof(*DEBUG_FLAGS);
        while (scan < stop) {
            if (flags & scan->bitflag) {
                printf ("    %s\n", scan->description);
            }
            scan++;
        }
    }

}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"PathObserver (%@) dealloc", filePath);
#endif
    FSEventStreamStop(stream);
    FSEventStreamInvalidate(stream);
    
}

@end



