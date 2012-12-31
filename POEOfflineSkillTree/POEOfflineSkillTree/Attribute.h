//
//  Attribute.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/30/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Build;

@interface Attribute : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * isBase;
@property (nonatomic, retain) NSNumber * assignedClass;
@property (nonatomic, retain) NSSet *skillNode;
@property (nonatomic, retain) NSSet *buildAttributes;
@end

@interface Attribute (CoreDataGeneratedAccessors)

- (void)addSkillNodeObject:(NSManagedObject *)value;
- (void)removeSkillNodeObject:(NSManagedObject *)value;
- (void)addSkillNode:(NSSet *)values;
- (void)removeSkillNode:(NSSet *)values;

- (void)addBuildAttributesObject:(Build *)value;
- (void)removeBuildAttributesObject:(Build *)value;
- (void)addBuildAttributes:(NSSet *)values;
- (void)removeBuildAttributes:(NSSet *)values;

@end
