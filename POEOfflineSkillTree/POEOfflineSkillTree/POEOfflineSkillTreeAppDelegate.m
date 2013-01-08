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
@synthesize buildNameField = _buildNameField;
@synthesize buildUrlField = _buildUrlField;
@synthesize buildListTableView = _buildListTableView;
@synthesize buildDisplayTableView = _buildDisplayTableView;
@synthesize buildDisplayData = _buildDisplayData;

BOOL terminateWithoutSave = NO;

#pragma mark Application Methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Starting Application");
    _managedObjectContext = [self managedObjectContext];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    long int launchCount;
    
    launchCount = [defaults integerForKey:@"launchCount"] + 1;
    [defaults setInteger:launchCount forKey:@"launchCount"];//change once this is tested
    [defaults synchronize];
    
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    if ([arguments count] > 3) {
        launchCount = [arguments[4] integerValue];
    }
    
    _buildDisplayData = [NSMutableDictionary dictionary];
    [_buildListTableView setDoubleAction:@selector(buildViewDouble:)];
    
    if (launchCount <= 1) {
        POEOfflineSkillTreeImporter *skillTreeImporter = [POEOfflineSkillTreeImporter skillTreeImporter];
        NSLog(@"Database not found, creating now...");
        NSDictionary *spriteInfo = [skillTreeImporter getSkillSpriteInfo];
        [self downloadAssets:spriteInfo[@"inactiveSkillSprites"]
                activeSkills:spriteInfo[@"activeSkillSprites"]
                 otherAssets:[skillTreeImporter getAssetInfo]];
        [self createNodeGroups:[skillTreeImporter getNodeGroupInfo]];
        [self createSkillIcons:spriteInfo[@"inactiveSkillSprites"]
                  activeSkills:spriteInfo[@"activeSkillSprites"]];
        [self createSkillNodes:[skillTreeImporter getSkillNodeInfo]];
        
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
    
    if (terminateWithoutSave) {
        NSLog(@"Terminating without saving...");
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
    } else {
        NSLog(@"Data Saved");
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
    int count = 0;
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
            count++;
            NSDictionary *subVars = [[NSDictionary alloc] initWithObjectsAndKeys:nodeId, @"gggNodeId", nil];
            fetchRequest = [mom fetchRequestFromTemplateWithName:@"fetchNodeWithGGGNodeId"
                                           substitutionVariables:subVars];
            //            NSLog(@"%@", fetchRequest);
            NSArray *result = [moc executeFetchRequest:fetchRequest error:&fetchError];
            //            NSLog(@"%@ %lu", result, [result count]);
            if (fetchError) {
                [[NSApplication sharedApplication] presentError:fetchError];
                terminateWithoutSave = YES;
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
    NSLog(@"Node Groups Created %d", count);
}

- (void) createSkillNodes:(NSArray *)nodeInfo {
    NSError *fetchError = nil;
    NSError *error = nil;
    NSFetchRequest *fetchRequest = nil;
    NSManagedObjectModel *mom = [self managedObjectModel];
    NSManagedObjectContext *moc = [self managedObjectContext];
    //create data store
    NSLog(@"Creating skill nodes");
    for (NSDictionary *node in nodeInfo) {
        NSNumber *nodeId = node[@"id"];
        NSDictionary *subVars = [NSDictionary dictionaryWithObject:nodeId forKey: @"gggNodeId"];
        fetchRequest = [mom fetchRequestFromTemplateWithName:@"fetchNodeWithGGGNodeId"
                                       substitutionVariables:subVars];
        //        NSLog(@"%@", fetchRequest);
        NSArray *result = [moc executeFetchRequest:fetchRequest error:&fetchError];
        //        NSLog(@"%@", result);
        if (fetchError) {
            [[NSApplication sharedApplication] presentError:fetchError];
            terminateWithoutSave = YES;
            [[NSApplication sharedApplication] terminate:self];
        }
        SkillNode * skillNode = result[0];
        skillNode.name = node[@"dn"];
        skillNode.a = node[@"a"];
        skillNode.orbit = node[@"o"];
        skillNode.orbitIndex = node[@"oidx"];
        skillNode.icon = node[@"icon"];
        skillNode.g = node[@"g"];
        skillNode.da = node[@"da"];
        skillNode.ia = node[@"ia"];
        skillNode.notVar = node[@"not"];
        skillNode.sa = node[@"sa"];
        skillNode.isMastery = node[@"m"];
        [skillNode generateArc];
        [skillNode generateLocation];
        
        /* Initialize attributes */
        NSLog(@"Initializing attributes for node: %@", skillNode.nodeId);
        for (NSString *attribute in node[@"sd"]) {
            NSRegularExpression *regex = [[NSRegularExpression alloc]
                                          initWithPattern:@"[0-9]*\\.?[0-9]+"
                                          options:0 error:&error];
            NSArray *matches = [regex matchesInString:attribute options:0 range:NSMakeRange(0, [attribute length])];
            NSString *attributeName = nil;
            float attributeValue;
            NSMutableArray *values = [[NSMutableArray alloc] init];
            
            for (NSTextCheckingResult *match in matches) {
                attributeValue = [[attribute substringWithRange:[match range]] floatValue];
                [values addObject:[NSNumber numberWithFloat:attributeValue]];
            }
            attributeName = [regex stringByReplacingMatchesInString:attribute
                            options:0 range:NSMakeRange(0, [attribute length])
                                                       withTemplate:@"#"];
            if (attributeName) {
                Attribute *newAttribute = [NSEntityDescription insertNewObjectForEntityForName:@"Attribute"
                                                                        inManagedObjectContext:moc];
                [newAttribute addSkillNodeObject:skillNode];
                newAttribute.values = values;
                newAttribute.name = attributeName;
                newAttribute.numValues = [NSNumber numberWithInteger:[values count]];
                [skillNode addAttributesObject:newAttribute];
            }
        }
        
        /* Initialize links */
        NSLog(@"Initializing links for node: %@", skillNode.nodeId);
        if ([node[@"out"] count] > 0) {
            for (NSNumber *linkId in node[@"out"]) {
                NSDictionary *subVars = [[NSDictionary alloc] initWithObjectsAndKeys:node[@"id"], @"gggNodeId", nil];
                fetchRequest = [mom fetchRequestFromTemplateWithName:@"fetchNodeWithGGGNodeId"
                                               substitutionVariables:subVars];
                NSArray *result = [moc executeFetchRequest:fetchRequest error:&fetchError];
                if (fetchError) {
                    [[NSApplication sharedApplication] presentError:fetchError];
                    terminateWithoutSave = YES;
                    [[NSApplication sharedApplication] terminate:self];
                }
                if ([result count] > 0) {
                    SkillNode * linkSkillNode = result[0];
                    [skillNode addLinkObject:linkSkillNode];
                }
            }
        }
        
        /* Link Skill Icons */
        NSLog(@"Linking Skill Icons for node: %@", skillNode.nodeId);
        subVars = [NSDictionary  dictionaryWithObject:skillNode.icon forKey:@"NODEMAP"];
        //        NSLog(@"%@", subVars);
        fetchRequest = [mom fetchRequestFromTemplateWithName:@"fetchSkillIconFromNodeMap"
                                       substitutionVariables:subVars];
        //        NSLog(@"%@", fetchRequest);
        result = [moc executeFetchRequest:fetchRequest error:&fetchError];
        //        NSLog(@"%@", result);
        if (fetchError) {
            [[NSApplication sharedApplication] presentError:fetchError];
            terminateWithoutSave = YES;
            [[NSApplication sharedApplication] terminate:self];
        }
        if ([result count] > 0) {
            for (SkillIcon *skillIcon in result) {
                if (skillIcon.isActive) {
                    skillNode.activeIcon = skillIcon;
                } else {
                    skillNode.inactiveIcon = skillIcon;
                }
            }
        }
    }
}

-(void) createSkillIcons:(NSArray *)inactiveSkills
            activeSkills:(NSArray *)activeSkills {
    NSManagedObjectContext *moc = [self managedObjectContext];
    for (NSArray *skillIcon in inactiveSkills) {
        SkillIcon *newSkillIcon = [NSEntityDescription insertNewObjectForEntityForName:@"SkillIcon"
                                                                inManagedObjectContext:moc];
        newSkillIcon.isActive = NO;
        newSkillIcon.fileName = skillIcon[0];
        newSkillIcon.nodeMap =  skillIcon[1];
        newSkillIcon.location = skillIcon[2];
    }
    for (NSArray *skillIcon in activeSkills) {
        SkillIcon *newSkillIcon = [NSEntityDescription insertNewObjectForEntityForName:@"SkillIcon"
                                                                inManagedObjectContext:moc];
        newSkillIcon.isActive = [NSNumber numberWithBool:YES];
        newSkillIcon.fileName = skillIcon[0];
        newSkillIcon.nodeMap =  skillIcon[1];
        newSkillIcon.location = skillIcon[2];
    }
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

#pragma mark New Build Window

- (IBAction)showNewBuildSheet:(id)sender {
    [NSApp beginSheet:_buildSheetNew modalForWindow:_window modalDelegate:nil
       didEndSelector:NULL contextInfo:NULL];
}

- (IBAction)endNewBuildSheet:(id)sender {
    NSError *fetchError = nil;
    NSFetchRequest *fetchRequest = nil;
    NSManagedObjectModel *mom = [self managedObjectModel];
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    [NSApp endSheet:_buildSheetNew];
    [_buildSheetNew orderOut:sender];
    
    NSString *buildName = [_buildNameField stringValue];
    NSString *buildUrl  = [_buildUrlField stringValue];
    NSDictionary *subVars = [NSDictionary dictionaryWithObjectsAndKeys:buildName,
                             @"BUILD_NAME", buildUrl, @"BUILD_URL", nil];
    NSLog(@"%@", subVars);
    NSLog(@"Searching for build Name: %@ URL: %@", buildName, buildUrl);
    
    fetchRequest = [mom fetchRequestFromTemplateWithName:@"fetchBuildWithURLAndName"
                                   substitutionVariables:subVars];
    NSArray *result = [moc executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        [NSApp presentError:fetchError];
    }
    if ([result count] > 0) {
        NSLog(@"Build Already found");
        [moc deleteObject:result[0]];
    } else {
        Build *newBuild = [NSEntityDescription insertNewObjectForEntityForName:@"Build"
                                                        inManagedObjectContext:moc];
        newBuild.name = buildName;
        newBuild.buildUrl = buildUrl;
        NSArray *skilledNodes = [newBuild decodeURL];
        for (NSObject *node in skilledNodes) {
            if ([node isKindOfClass:[NSString class]]) {
                subVars = [NSDictionary dictionaryWithObject:node forKey:@"nodeName"];
                fetchRequest = [mom fetchRequestFromTemplateWithName:@"fetchNodeByName"
                                               substitutionVariables:subVars];
                result = [moc executeFetchRequest:fetchRequest error:&fetchError];
                if (fetchError) {
                    [NSApp presentError:fetchError];
                }
                if ([result count] > 0) {
                    SkillNode *activateMe = result[0];
                    [newBuild addActiveNodesObject:activateMe];
                    activateMe.isActivated = [NSNumber numberWithBool:YES];
                    NSSet *links = activateMe.link;
                    for (SkillNode *link in links) {
                        link.canBeActivated = [NSNumber numberWithBool:YES];
                    }
                }
            } else {
                subVars = [NSDictionary dictionaryWithObject:node forKey:@"gggNodeId"];
                fetchRequest = [mom fetchRequestFromTemplateWithName:@"fetchNodeWithGGGNodeId"
                                               substitutionVariables:subVars];
                result = [moc executeFetchRequest:fetchRequest error:&fetchError];
                if (fetchError) {
                    [NSApp presentError:fetchError];
                }
                if ([result count] > 0) {
                    SkillNode *activateMe = result[0];
                    [newBuild addActiveNodesObject:activateMe];
                    activateMe.isActivated = [NSNumber numberWithBool:YES];
                    NSSet *links = activateMe.link;
                    for (SkillNode *link in links) {
                        link.canBeActivated = [NSNumber numberWithBool:YES];
                    }
                }
            }
        }
    }
    
}

- (IBAction)endNewBuildSheetCanceled:(id)sender {
    [NSApp endSheet:_buildSheetNew];
    [_buildSheetNew orderOut:sender];
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

#pragma mark Build List Methods

-(void)tableViewSelectionIsChanging:(NSNotification *) notification {
//    NSTableView *temp = [notification object];
//    if (temp == _buildListTableView) {
//        Build *selectedBuild = [buildListController selectedObjects][0];
//        NSLog(@"Is changing: %@", selectedBuild);
//    } else if (temp == _buildDisplayTableView) {
//        NSLog(@"DISPLAY");
//    }
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSManagedObjectContext * moc = [self managedObjectContext];
    NSManagedObjectModel * mom = [self managedObjectModel];
    NSFetchRequest *fetchRequest = nil;
    NSError *fetchError = nil;
    
    NSTableView *temp = [notification object];
    if (temp == _buildListTableView) {
        Build *selectedBuild = [buildListController selectedObjects][0];
        NSMutableDictionary *attributeAggregator = nil;
        attributeAggregator = [NSMutableDictionary dictionary];
        NSMutableDictionary *numValues = [NSMutableDictionary dictionary];
        NSArray *valueArray;
        
        for (SkillNode *active in selectedBuild.activeNodes) {
            for (Attribute *attribute in active.attributes) {
                NSString *attrName = attribute.name;
                valueArray = [attribute.values mutableCopy];
                NSMutableArray *obj = [attributeAggregator objectForKey:attribute.name];
                if (obj) {
                    for (int ndx = 0; ndx < [obj count]; ndx++) {
                        obj[ndx] = [NSNumber numberWithFloat:([obj[ndx] floatValue] + [valueArray[ndx] floatValue])];
                    }
                    [attributeAggregator setValue:obj forKey:attrName];
                } else {
                    [attributeAggregator setValue:valueArray forKey:attrName];
                    [numValues setValue:attribute.numValues forKey:attrName];
                }
            }
        }
        
        NSMutableArray *finalAttributeList = nil;
        finalAttributeList = [NSMutableArray array];
        for (NSString *key in [attributeAggregator allKeys]) {
//            NSLog(@"%@", key);
            NSString *name = [key stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"];
//            NSLog(@"%@", name);
            NSDictionary *subVars = [NSDictionary dictionaryWithObject:name forKey:@"NAME"];
            fetchRequest = [mom fetchRequestFromTemplateWithName:@"fetchAttributeWithName"
                                           substitutionVariables:subVars];
            NSArray *results = [moc executeFetchRequest:fetchRequest error:&fetchError];
            
            NSString *finalAttribute = key;
            NSArray *values = attributeAggregator[key];
            Attribute *addAttribute = nil;
            
            BOOL found = NO;
            for (int ndx = 0; ndx < [results count] && !found; ndx++) {
                Attribute *attr = results[ndx];
                if ([attr.values isEqualToArray:values]) {
                    addAttribute = attr;
                    found = YES;
                }
            }
            if (addAttribute == nil) {
                addAttribute = [NSEntityDescription insertNewObjectForEntityForName:@"Attribute" inManagedObjectContext:moc];
                addAttribute.values = values;
                addAttribute.name = finalAttribute;
                addAttribute.numValues = [NSNumber numberWithInteger:[values count]];
            }
            
            for (int ndx = 0; ndx < [numValues[key] intValue]; ndx++) {
                finalAttribute = [finalAttribute replaceFirstOccurance:@"#"
                                                           replaceWith:[[values objectAtIndex:ndx] stringValue]];
                if (finalAttribute == nil) {
                    finalAttribute = key;
                }
            }
            //        NSLog(@"%@ %@", finalAttribute, numValues[key]);
            NSSet *buildAttrSet = selectedBuild.attributes;
            NSPredicate *setPredicate = [NSPredicate predicateWithFormat:@"name MATCHES %@", name];
            NSSet *filteredSet = [buildAttrSet filteredSetUsingPredicate:setPredicate];

            addAttribute.displayName = finalAttribute;
            
            [selectedBuild removeAttributes:filteredSet];
            [selectedBuild addAttributesObject:addAttribute];
            
            [finalAttributeList addObject:finalAttribute];
        }
    } else if (temp == _buildDisplayTableView) {
        NSLog(@"DISPLAY");
    }
}

-(IBAction)buildViewDouble:(id)sender {
    NSInteger row = [_buildListTableView selectedRow];
    if (row != -1) {
        NSLog(@"Double: %@", [(Build *)([buildListController selectedObjects][0]) valueForKey:@"buildUrl"]);
    }
}


@end
