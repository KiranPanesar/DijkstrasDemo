//
//  KPGraphCanvasView.h
//  DijkstrasDemo
//
//  Created by Kiran Panesar on 11/02/2013.
//  Copyright (c) 2013 MobileX Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KPGraphNodeView;

@protocol KPGraphCanvasViewDelegate <NSObject>

-(void)setStartPoint:(NSString *)startID andEndPoint:(NSString *)endID;

@end

@interface KPGraphCanvasView : UIView <UIAlertViewDelegate> {
    KPGraphNodeView *firstTappedNode;
    KPGraphNodeView *secondTappedNode;
    
    NSMutableDictionary *finalParings;
}

@property (strong, nonatomic) NSMutableArray *graphNodes;
@property (strong, nonatomic) NSMutableDictionary *nodeParings;
@property (strong, nonatomic) id<KPGraphCanvasViewDelegate> delegate;

@property BOOL addingNode;
@property BOOL settingPath;

-(void)showRouteBetweenFinalNodes:(NSMutableDictionary *)finalNodes;

@end
