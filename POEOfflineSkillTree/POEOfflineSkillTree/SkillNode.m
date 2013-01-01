//
//  SkillNode.m
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/31/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import "SkillNode.h"
#import "Attribute.h"
#import "Build.h"
#import "NodeGroup.h"
#import "SkillNode.h"


@implementation SkillNode

@dynamic a;
@dynamic canBeActivated;
@dynamic da;
@dynamic g;
@dynamic hitBox;
@dynamic ia;
@dynamic icon;
@dynamic iconFilename;
@dynamic iconLocation;
@dynamic isActivated;
@dynamic isMastery;
@dynamic ks;
@dynamic location;
@dynamic name;
@dynamic nodeId;
@dynamic notVar;
@dynamic orbit;
@dynamic orbitIndex;
@dynamic sa;
@dynamic arc;
@dynamic attributes;
@dynamic buildNodes;
@dynamic link;
@dynamic nodeGroup;

-(void)generateArc {
    double a = (2 * M_PI * [self.orbitIndex integerValue] / skillsPerOrbit[[self.orbit integerValue]]);
    
    self.arc = [NSNumber numberWithDouble:a];
}

-(void)generateLocation {
    double d = orbitRadii[[self.orbit integerValue]];
    double b = (2 * M_PI * [self.orbitIndex integerValue] / skillsPerOrbit[[self.orbit integerValue]]);
    double x = sin(-b) * d;
    double y = cos(-d) * b;
    
    NSPoint nodeGroupLoc = NSPointFromString(self.nodeGroup.position);
    NSPoint nodeLoc = NSMakePoint(nodeGroupLoc.x - x, nodeGroupLoc.y - y);
    
    self.location = NSStringFromPoint(nodeLoc);
}

@end
