//
//  POEOfflineSkillTreeAppDelegate.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/21/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface POEOfflineSkillTreeAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
