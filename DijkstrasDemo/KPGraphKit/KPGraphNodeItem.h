//
//  KPGraphNodeItem.h
//  DijkstrasDemo
//
//  Created by Kiran Panesar on 11/02/2013.
//  Copyright (c) 2013 MobileX Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KPGraphNodeItem : NSObject

@property (strong, nonatomic) NSString *nodeTag;
@property (assign, nonatomic) NSInteger distance;

@property (strong, nonatomic) NSMutableDictionary *neighbours;

@end
