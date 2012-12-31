//
//  POEOfflineSkillTreeAppDelegate.m
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/21/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import "POEOfflineSkillTreeAppDelegate.h"

@implementation POEOfflineSkillTreeAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize tabView = _tabView;

#pragma mark Application Methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Starting Application");
    _managedObjectContext = [self managedObjectContext];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    long int launchCount;
    
    launchCount = [defaults integerForKey:@"launchCount"] + 1;
    [defaults setInteger:0 forKey:@"launchCount"];//change once this is tested
    [defaults synchronize];
    
    if (launchCount <= 1) {
        POEOfflineSkillTreeImporter *skillTreeImporter = [POEOfflineSkillTreeImporter skillTreeImporter];
        NSLog(@"Database not found, creating now..");
        [self createNodeGroups:[skillTreeImporter getNodeGroupInfo]];
//        [self createSkillNodes:[skillTreeImporter getSkillNodeInfo]];
//        NSDictionary *spriteInfo = [skillTreeImporter getSkillSpriteInfo];
//        [self downloadAssets:spriteInfo[@"inactiveSkillSprites"]
//                     activeSkills:spriteInfo[@"activeSkillSprites"]
//                        otherAssets:[skillTreeImporter getAssetInfo]];
        
    } else {
        NSLog(@"NO LONGER FIRST LAUNCH");
        
        //test for data store
        //test for graphics
    }
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "EricBunton.POEOfflineSkillTree" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"POEOfflineSkillTree"];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    NSLog(@"Exiting...");
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Unresolved error %@", error);
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        NSLog(@"%d", result);
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

#pragma mark Core Data Methods

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"POEOfflineSkillTree" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
//    NSLog(@"PersistentStoreCoordinator");
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"POEOfflineSkillTree.xml"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    //NSLog(@"ManageObjectContext");
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

#pragma mark Initialization

-(void) createNodeGroups:(NSDictionary *) groupInfo {
    NSError *fetchError = nil;
    NSFetchRequest *fetchRequest = nil;
    NSManagedObjectModel *mom = [self managedObjectModel];
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    for (NSString *groupName in [groupInfo allKeys]) {
        NSDictionary * group = groupInfo[groupName];
        NSPoint loc = NSMakePoint([group[@"x"] floatValue], [group[@"y"] floatValue]);
        
        NodeGroup *newNodeGroup = [NSEntityDescription insertNewObjectForEntityForName:@"NodeGroup" inManagedObjectContext:moc];
        
        newNodeGroup.position = NSStringFromPoint(loc);
        newNodeGroup.name = groupName;
        if ([group[@"oo"] isMemberOfClass:[NSArray class]]) {
            newNodeGroup.ocpOrb = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"0", nil];
        } else {
            newNodeGroup.ocpOrb = group[@"oo"];
        }
        
        for (NSNumber *nodeId  in group[@"n"]) {
            NSDictionary *subVars = [[NSDictionary alloc] initWithObjectsAndKeys:nodeId, @"gggNodeId", nil];
            fetchRequest = [mom fetchRequestFromTemplateWithName:@"fetchNodeWithGGGNodeId"
                                           substitutionVariables:subVars];
            NSArray *result = [moc executeFetchRequest:fetchRequest error:&fetchError];
            if (fetchError) {
                [[NSApplication sharedApplication] presentError:fetchError];
                [[NSApplication sharedApplication] terminate:self];
            }
            if ([result count] == 0) {
                SkillNode *newSkillNode = [NSEntityDescription insertNewObjectForEntityForName:@"SkillNode"
                                                                        inManagedObjectContext:moc];
                newSkillNode.nodeId = nodeId;
                newSkillNode.nodeGroup = newNodeGroup;
                [newNodeGroup addNodesInGroupObject:newSkillNode];
            } else {
                SkillNode *skillNode = result[0];
                [skillNode setValue:newNodeGroup forKey:@"nodeGroup"];
                [newNodeGroup addNodesInGroupObject:skillNode];
            }
        }
    }
    NSLog(@"Node Groups Created");
}

- (void) createSkillNodes:(NSArray *)nodeInfo {
    NSError *error = nil;
    //create data store
    NSLog(@"Creating skill nodes");
    for (NSDictionary *node in nodeInfo) {
//        SkillNode *newNode = [NSEntityDescription insertNewObjectForEntityForName:@"SkillNode" inManagedObjectContext:[self managedObjectContext]];
//        [newNode setValue:node[@"dn"] forKey:@"name"];
//        [newNode setValue:node[@"id"] forKey:@"nodeId"];
//        [newNode setValue:node[@"a"] forKey:@"a"];
//        [newNode setValue:node[@"o"] forKey:@"orbit"];
//        [newNode setValue:node[@"oidx"] forKey:@"orbitIndex"];
//        [newNode setValue:node[@"icon"] forKey:@"icon"];
//        
////        newNode.linkIds = [[NSArray alloc] initWithArray:node[@"out"]];
//        
//        [newNode setValue:node[@"g"] forKey:@"g"];
//        [newNode setValue:node[@"da"] forKey:@"da"];
//        [newNode setValue:node[@"ia"] forKey:@"ia"];
//        [newNode setValue:node[@"ks"] forKey:@"ks"];
//        [newNode setValue:node[@"not"] forKey:@"notVar"];
//        [newNode setValue:node[@"sa"] forKey:@"sa"];
//        [newNode setValue:node[@"m"] forKey:@"isMastery"];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSString *attribute in node[@"sd"]) {NSLog(@"%@",attribute);
//            NSRegularExpression *regex = [[NSRegularExpression alloc]
//                                          initWithPattern:@"[0-9]*\\.?[0-9]+"
//                                          options:0 error:&error];
//            NSArray *matches = [regex matchesInString:attribute options:0 range:NSMakeRange(0, [attribute length])];
//            NSString *attributeName = nil;
//            NSInteger attributeValue;
//            NSMutableArray *values = [[NSMutableArray alloc] init];
//            
//            for (NSTextCheckingResult *match in matches) {
//                attributeName = [attribute stringByReplacingCharactersInRange:[match range] withString:@"#"];
//                attributeValue = [[attribute substringWithRange:[match range]] integerValue];
//                [values addObject:[NSNumber numberWithLong:attributeValue]];
//            }
//            if (attributeName) {
//                [dict setValue:values forKey:attributeName];
//            }
        }
//        [newNode setValue:dict forKey:@"attributes"];
    
    }
    
    //initialize links once all nodes are created
    NSLog(@"Creating links/relationships");
}

- (void) downloadAssets:(NSArray *)inactiveSkills
           activeSkills:(NSArray *)activeSkills
            otherAssets:(NSDictionary *) otherAssets {
    NSLog(@"Downloading assets");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSURL *assetLocation = [[self applicationFilesDirectory] URLByAppendingPathComponent:@"Data/Assets/"];
    NSString *assetLocationPath = [[assetLocation path] stringByAppendingString:@"/"];
    NSURL *skillIconUrl = [NSURL URLWithString:POEIconAddress];
    NSURLRequest *request =  nil;
    
    [fileManager createDirectoryAtURL:assetLocation withIntermediateDirectories:YES attributes:nil error:&error];
    
    
    //Download Inactive Skill Sprites
    for (NSArray *type in inactiveSkills) {
        NSString *fileName = type[0];
        request = [NSURLRequest requestWithURL:[skillIconUrl URLByAppendingPathComponent:fileName]
                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                               timeoutInterval:30];
        
        NSURLResponse *response = nil;
        if (![fileManager fileExistsAtPath:[assetLocationPath stringByAppendingString:fileName]]) {
            NSLog(@"Downloading file: %@", fileName);
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (!error && [data length] > 0) {
                [data writeToURL:[assetLocation URLByAppendingPathComponent:fileName] options:NSDataWritingAtomic error:&error];
                if (error) {
                    [[NSApplication sharedApplication] presentError:error];
                }
            } else {
                [[NSApplication sharedApplication] presentError:error];
            }
        }
    }
    
    
    //Download Active Skill Sprites
    for (NSArray *type in activeSkills) {
        NSString *fileName = type[0];
        request = [NSURLRequest requestWithURL:[skillIconUrl URLByAppendingPathComponent:fileName]
                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                               timeoutInterval:30];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        if (![fileManager fileExistsAtPath:[assetLocationPath stringByAppendingString:fileName]]) {
            NSLog(@"Downloading file: %@", fileName);
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (!error && [data length] > 0) {
                [data writeToURL:[assetLocation URLByAppendingPathComponent:fileName] options:NSDataWritingAtomic error:&error];
                if (error) {
                    [[NSApplication sharedApplication] presentError:error];
                }
            } else {
                [[NSApplication sharedApplication] presentError:error];
            }
        }
    }
    
    //Download other assets Sprites
    for (NSString *file in [otherAssets allKeys]) {
        NSURL *url = [NSURL URLWithString:otherAssets[file]];
        request = [NSURLRequest requestWithURL:url
                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                               timeoutInterval:30];
        
        NSString *fileName = [file stringByAppendingString:@".png"];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        if (![fileManager fileExistsAtPath:[assetLocationPath stringByAppendingString:fileName]]) {
            NSLog(@"Downloading file: %@", otherAssets[file]);
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (!error && [data length] > 0) {
                [data writeToURL:[assetLocation URLByAppendingPathComponent:fileName] options:NSDataWritingAtomic error:&error];
                if (error) {
                    [[NSApplication sharedApplication] presentError:error];
                }
            } else {
                [[NSApplication sharedApplication] presentError:error];
            }
        }
    }
    NSLog(@"Assets downloaded.");
}


#pragma mark Tab View Methods

- (IBAction)selectStatsTab:(id)sender {
    NSTabViewItem *statsTab = [_tabView tabViewItemAtIndex:0];
    [_tabView selectTabViewItem:statsTab];
}

- (IBAction)selectTreeTab:(id)sender {
    NSTabViewItem *treeTab = [_tabView tabViewItemAtIndex:1];
    [_tabView selectTabViewItem:treeTab];
}

- (IBAction)selectItemsTab:(id)sender {
    NSTabViewItem *itemsTab = [_tabView tabViewItemAtIndex:2];
    [_tabView selectTabViewItem:itemsTab];
}

@end
