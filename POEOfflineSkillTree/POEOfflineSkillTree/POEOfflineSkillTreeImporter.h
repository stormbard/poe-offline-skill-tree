//
//  POEOfflineSkillTreeImporter.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/26/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"
#import "Constants.h"
#import "NSString+Contains.h"

@interface POEOfflineSkillTreeImporter : NSObject 


+(id)skillTreeImporter;
-(NSArray *) getSkillNodeInfo;
-(NSDictionary *) getSkillSpriteInfo;
-(NSDictionary *)getAssetInfo;
-(NSDictionary *)getNodeGroupInfo;
-(NSString *) getJson;

@end
