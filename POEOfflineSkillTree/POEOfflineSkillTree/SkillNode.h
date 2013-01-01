//
//  SkillNode.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/31/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Constants.h"

@class Attribute, Build, NodeGroup, SkillIcon, SkillNode;

@interface SkillNode : NSManagedObject

@property (nonatomic, retain) NSNumber * a;
@property (nonatomic, retain) NSNumber * canBeActivated;
@property (nonatomic, retain) NSNumber * da;
@property (nonatomic, retain) NSNumber * g;
@property (nonatomic, retain) NSString * hitBox;
@property (nonatomic, retain) NSNumber * ia;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSNumber * isActivated;
@property (nonatomic, retain) NSNumber * isMastery;
@property (nonatomic, retain) NSNumber * ks;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSNumber * notVar;
@property (nonatomic, retain) NSNumber * orbit;
@property (nonatomic, retain) NSNumber * orbitIndex;
@property (nonatomic, retain) NSNumber * sa;
@property (nonatomic, retain) NSNumber * arc;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) NSSet *buildNodes;
@property (nonatomic, retain) NSSet *link;
@property (nonatomic, retain) NodeGroup *nodeGroup;
@property (nonatomic, retain) SkillIcon *activeIcon;
@property (nonatomic, retain) SkillIcon *inactiveIcon;

-(void)generateArc;
-(void)generateLocation;
@end

@interface SkillNode (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(Attribute *)value;
- (void)removeAttributesObject:(Attribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addBuildNodesObject:(Build *)value;
- (void)removeBuildNodesObject:(Build *)value;
- (void)addBuildNodes:(NSSet *)values;
- (void)removeBuildNodes:(NSSet *)values;

- (void)addLinkObject:(SkillNode *)value;
- (void)removeLinkObject:(SkillNode *)value;
- (void)addLink:(NSSet *)values;
- (void)removeLink:(NSSet *)values;

@end
