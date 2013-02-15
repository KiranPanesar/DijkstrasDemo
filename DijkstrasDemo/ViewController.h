//
//  ViewController.h
//  DijkstrasDemo
//
//  Created by Kiran Panesar on 11/02/2013.
//  Copyright (c) 2013 MobileX Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KPGraphNodeView;
@class KPGraphCanvasView;

@interface ViewController : UIViewController <UIAlertViewDelegate> {
    NSMutableArray *graphNodes;
    NSMutableDictionary *nodeParings;
    
    NSString *startID;
    NSString *endID;
    
    BOOL addingNode;
    
    UIAlertView *firstNodeAlert;
    UIAlertView *secondNodeAlert;
    
    IBOutlet KPGraphCanvasView *graphCanvasView;
    IBOutlet UINavigationBar *navigationBar;
}

- (IBAction)pushAddNode:(id)sender;
- (IBAction)pushFindPath:(id)sender;

-(void)findRouteWithStart:(NSString *)startNode end:(NSString *)endNode;

@end
