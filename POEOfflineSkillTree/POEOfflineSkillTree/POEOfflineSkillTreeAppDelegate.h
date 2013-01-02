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
#import "SkillIcon.h"

@interface POEOfflineSkillTreeAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *buildSheetNew;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSTextField *buildUrlField;
@property (assign) IBOutlet NSTextField *buildNameField;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

- (IBAction)selectStatsTab:(id)sender;
- (IBAction)selectTreeTab:(id)sender;
- (IBAction)selectItemsTab:(id)sender;

- (IBAction)showNewBuildSheet:(id)sender;
- (IBAction)endNewBuildSheet:(id)sender;
- (IBAction)endNewBuildSheetCanceled:(id)sender;

@end
