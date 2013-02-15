//
//  ViewController.m
//  DijkstrasDemo
//
//  Created by Kiran Panesar on 11/02/2013.
//  Copyright (c) 2013 MobileX Labs. All rights reserved.
//

#import "ViewController.h"
#import "KPGraphNodeView.h"
#import "KPGraphCanvasView.h"

#import "KPGraphNodeItem.h"

#import "KPGraphResolver.h"

#define NODE_PARING(node1, node2) [NSArray arrayWithObjects:node1, node2, nil]

@interface ViewController ()

@end

@implementation ViewController


-(IBAction)pushAddNode:(id)sender {
    graphCanvasView.addingNode = !graphCanvasView.addingNode;
    [[navigationBar topItem] setTitle:@"Dijkstra's"];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == firstNodeAlert) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Set"]) {
            startID = [[alertView textFieldAtIndex:0] text];
            
            secondNodeAlert = [[UIAlertView alloc] initWithTitle:@"Set End Node"
                                                        message:@"Enter the end node ID"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Set", nil];
            
            [secondNodeAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[secondNodeAlert textFieldAtIndex:0] setPlaceholder:[NSString stringWithFormat:@"Enter node ID"]];
            [secondNodeAlert show];
        }
    } else if (alertView == secondNodeAlert) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Set"]) {
            endID = [[alertView textFieldAtIndex:0] text];
        }
        [self findRouteWithStart:startID end:endID];
    }
}

-(IBAction)pushFindPath:(id)sender {
    firstNodeAlert = [[UIAlertView alloc] initWithTitle:@"Set Start Node"
                                                 message:@"Enter the start node ID"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Set", nil];
    
    [firstNodeAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[firstNodeAlert textFieldAtIndex:0] setPlaceholder:[NSString stringWithFormat:@"Enter node ID"]];
    [firstNodeAlert show];
}

-(void)findRouteWithStart:(NSString *)startNode end:(NSString *)endNode {
    NSMutableDictionary *connections = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *nodes = [[NSMutableDictionary alloc] init];
    
    for (NSArray *pairings in graphCanvasView.nodeParings) {
        
        KPGraphNodeItem *firstItem = [[KPGraphNodeItem alloc] init];
        firstItem.nodeTag = [(KPGraphNodeView *)[pairings objectAtIndex:0] nodeTag];
        firstItem.neighbours = [[NSMutableDictionary alloc] init];
        
        KPGraphNodeItem *secondItem = [[KPGraphNodeItem alloc] init];
        secondItem.nodeTag = [(KPGraphNodeView *)[pairings objectAtIndex:1] nodeTag];
        secondItem.neighbours = [[NSMutableDictionary alloc] init];
        
        for (NSArray *array in graphCanvasView.nodeParings) {
            NSInteger arcWeight = [self weightBetween:firstItem.nodeTag and:secondItem.nodeTag inConnections:graphCanvasView.nodeParings];
            
            if (arcWeight != INFINITY) {
                [connections setObject:[NSNumber numberWithInteger:arcWeight]
                                forKey:@[firstItem, secondItem]];
            }
        }
    }
    
    for (KPGraphNodeView *n in graphCanvasView.graphNodes) {
        KPGraphNodeItem *item = [[KPGraphNodeItem alloc] init];
        item.nodeTag = n.nodeTag;
        item.neighbours = [[NSMutableDictionary alloc] init];
        
        [nodes setObject:item forKey:item.nodeTag];
    }
    
    KPGraphResolver *resolver = [[KPGraphResolver alloc] init];
    
    [resolver dijkstrasOnConnections:connections
                               nodes:nodes
                       withStartNode:startNode
                             endNode:endNode
                andCompletionHandler:^(NSMutableArray *path, NSInteger weight) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [graphCanvasView showRouteBetweenFinalNodes:path];
                        
                        NSMutableString *pathString = [[NSMutableString alloc] init];
                        for (NSString *node in path) {
                            [pathString appendString:node];
                            if (![node isEqualToString:[path objectAtIndex:[path count]-1]]) {
                                [pathString appendString:@", "];
                            }
                        }
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Optimum Path Found!"
                                                                            message:[NSString stringWithFormat:@"Optimum path found\n%@\n Weight %i",pathString, weight]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Dismiss"
                                                                  otherButtonTitles:nil, nil];
                        [alertView show];
                    });
                }];
}

-(NSInteger)weightBetween:(NSString *)nodeOne and:(NSString *)nodeTwo inConnections:(NSMutableDictionary *)connections {
    for (NSArray *array in connections) {
        if (([[[array objectAtIndex:0] nodeTag] isEqualToString:nodeOne] || [[[array objectAtIndex:0] nodeTag] isEqualToString:nodeTwo])
            && ([[[array objectAtIndex:1] nodeTag] isEqualToString:nodeOne] || [[[array objectAtIndex:1] nodeTag] isEqualToString:nodeTwo])) {
            return [[connections objectForKey:array] integerValue];
        }
    }
    return INFINITY;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    graphNodes = [[NSMutableArray alloc] init];
    nodeParings = [[NSMutableDictionary alloc] init];
    
    graphCanvasView.graphNodes = [[NSMutableArray alloc] init];
    graphCanvasView.nodeParings = [[NSMutableDictionary alloc] init];
    
    addingNode = FALSE;
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
