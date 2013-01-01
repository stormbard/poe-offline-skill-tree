//
//  SkillIcon.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/31/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SkillNode;

@interface SkillIcon : NSManagedObject

@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) SkillNode *active;
@property (nonatomic, retain) SkillNode *inactive;

@end
