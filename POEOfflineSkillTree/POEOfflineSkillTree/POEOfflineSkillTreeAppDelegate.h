//
//  POEOfflineSkillTreeAppDelegate.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/21/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "POEOfflineSkillTreeImporter.h"
#import "NodeGroup.h"
#import "SkillNode.h"
#import "Build.h"
#import "Attribute.h"

@interface POEOfflineSkillTreeAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTabView * tabView;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

- (IBAction)selectStatsTab:(id)sender;
- (IBAction)selectTreeTab:(id)sender;
- (IBAction)selectItemsTab:(id)sender;

@end
