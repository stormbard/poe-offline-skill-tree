//
//  Attribute.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 1/5/13.
//  Copyright (c) 2013 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Build, SkillNode;

@interface Attribute : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * numValues;
@property (nonatomic, retain) NSArray * values;
@property (nonatomic, retain) NSSet *skillNode;
@property (nonatomic, retain) NSSet *builds;
@end

@interface Attribute (CoreDataGeneratedAccessors)

- (void)addSkillNodeObject:(SkillNode *)value;
- (void)removeSkillNodeObject:(SkillNode *)value;
- (void)addSkillNode:(NSSet *)values;
- (void)removeSkillNode:(NSSet *)values;

- (void)addBuildsObject:(Build *)value;
- (void)removeBuildsObject:(Build *)value;
- (void)addBuilds:(NSSet *)values;
- (void)removeBuilds:(NSSet *)values;

@end
