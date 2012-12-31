//
//  NodeGroup.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/30/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NodeGroup : NSManagedObject

@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSDictionary * ocpOrb;//Cannot search via this
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *nodesInGroup;
@end

@interface NodeGroup (CoreDataGeneratedAccessors)

- (void)addNodesInGroupObject:(NSManagedObject *)value;
- (void)removeNodesInGroupObject:(NSManagedObject *)value;
- (void)addNodesInGroup:(NSSet *)values;
- (void)removeNodesInGroup:(NSSet *)values;

@end
