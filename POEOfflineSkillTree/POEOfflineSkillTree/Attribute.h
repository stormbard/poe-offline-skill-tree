//
//  Attribute.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/31/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SkillNode;

@interface Attribute : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSArray * values;
@property (nonatomic, retain) NSNumber * numValues;
@property (nonatomic, retain) NSSet *skillNode;
@end

@interface Attribute (CoreDataGeneratedAccessors)

- (void)addSkillNodeObject:(SkillNode *)value;
- (void)removeSkillNodeObject:(SkillNode *)value;
- (void)addSkillNode:(NSSet *)values;
- (void)removeSkillNode:(NSSet *)values;

@end
