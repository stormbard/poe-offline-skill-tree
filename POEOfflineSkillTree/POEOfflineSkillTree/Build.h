//
//  Build.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 1/5/13.
//  Copyright (c) 2013 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Constants.h"
#import "NSString+Base64.h"
#import "NSString+Contains.h"

@class Attribute, SkillNode;

@interface Build : NSManagedObject

@property (nonatomic, retain) NSString * buildUrl;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *activeNodes;
@property (nonatomic, retain) NSSet *attributes;

-(NSArray *)decodeURL;
-(void)encodeURL;

@end

@interface Build (CoreDataGeneratedAccessors)

- (void)addActiveNodesObject:(SkillNode *)value;
- (void)removeActiveNodesObject:(SkillNode *)value;
- (void)addActiveNodes:(NSSet *)values;
- (void)removeActiveNodes:(NSSet *)values;

- (void)addAttributesObject:(Attribute *)value;
- (void)removeAttributesObject:(Attribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

@end
