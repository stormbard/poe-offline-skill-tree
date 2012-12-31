//
//  Build.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/30/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Attribute;

@interface Build : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * buildUrl;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSSet *activeNodes;
@property (nonatomic, retain) NSSet *attributes;
@end

@interface Build (CoreDataGeneratedAccessors)

- (void)addActiveNodesObject:(NSManagedObject *)value;
- (void)removeActiveNodesObject:(NSManagedObject *)value;
- (void)addActiveNodes:(NSSet *)values;
- (void)removeActiveNodes:(NSSet *)values;

- (void)addAttributesObject:(Attribute *)value;
- (void)removeAttributesObject:(Attribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

@end
