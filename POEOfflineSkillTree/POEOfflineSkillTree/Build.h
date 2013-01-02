//
//  Build.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/31/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "Constants.h"

@class SkillNode;

@interface Build : NSManagedObject

@property (nonatomic, retain) NSString * buildUrl;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *activeNodes;

-(NSArray *)decodeURL;
-(void)encodeURL;
@end

@interface Build (CoreDataGeneratedAccessors)

- (void)addActiveNodesObject:(SkillNode *)value;
- (void)removeActiveNodesObject:(SkillNode *)value;
- (void)addActiveNodes:(NSSet *)values;
- (void)removeActiveNodes:(NSSet *)values;

@end
