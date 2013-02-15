//
//  KPGraphResolver.m
//  DijkstrasDemo
//
//  Created by Kiran Panesar on 11/02/2013.
//  Copyright (c) 2013 MobileX Labs. All rights reserved.
//

#import "KPGraphResolver.h"
#import "KPGraphNodeItem.h"

@implementation KPGraphResolver

-(void)dijkstrasOnConnections:(NSMutableDictionary *)connections nodes:(NSMutableDictionary *)nodes withStartNode:(NSString *)startID endNode:(NSString *)endID andCompletionHandler:(void (^)(NSMutableArray *, NSInteger))callback {
    
    // No nodes are currently connected
    for (int i = 0; i < [[nodes allKeys] count]; i++) {
        KPGraphNodeItem *currentItem = [nodes objectForKey:[[nodes allKeys] objectAtIndex:i]];
        currentItem.distance = INFINITY;
    }
    
    
    // Parse through all of the provided connections
    // and set up the neighbour relationships for each node
    for (NSArray *pair in connections) {
        // Each node's nieghbours are stored in an NSMutableDictionary holding the neighbours ID
        // and the distance from the node
        [[[nodes objectForKey:[[pair objectAtIndex:0] nodeTag]] neighbours] setObject:[connections objectForKey:pair] forKey:[[pair objectAtIndex:1] nodeTag]];
        [[[nodes objectForKey:[[pair objectAtIndex:1] nodeTag]] neighbours] setObject:[connections objectForKey:pair] forKey:[[pair objectAtIndex:0] nodeTag]];
    }
    
    // Add the start node to the graph
    [[nodes objectForKey:startID] setDistance:0];
    
    // Create a store for all the unparsed nodes in the graph
    // Once parsed, each node will be removed from here
    NSMutableDictionary *duplicationNodes = [NSMutableDictionary dictionaryWithDictionary:nodes];
    
    // Set up the currentNode to the start node of the graph
    KPGraphNodeItem *currentNode;
    currentNode = [duplicationNodes objectForKey:startID];
    
    
    // Sort the nodes now. This will make sorting them quicker (fewer passes of algorithm)
    // in the future
    duplicationNodes = [self sortNodes:duplicationNodes];
    
    // While there are unscanned nodes still in graph...
    while ([[duplicationNodes allKeys] count] > 0) {
        
        // Find the shortest node on the graph and work from that
        NSString *shortID = [self lightestNodeOnGraph:duplicationNodes];
        currentNode = [duplicationNodes objectForKey:shortID];
        [duplicationNodes removeObjectForKey:currentNode.nodeTag]; // Set the shortest node as 'scanned'
        
        NSLog(@"Working from node: %@", currentNode.nodeTag);
        
        // Check all of the neighbors of the shortest node
        for (NSString *neighbour in currentNode.neighbours) {
            
            // Get neighbour's distance if linked via current node
            NSInteger distance = currentNode.distance + [[currentNode.neighbours objectForKey:neighbour] integerValue];
            
            // See if the neighbour's old distance is greater than the potential new distance
            if ([[nodes objectForKey:neighbour] distance] > distance)
                [[nodes objectForKey:neighbour] setDistance:distance]; // If so, update the neighbour's distance
        }
        
        // This is a hacky method to make sure that the start node is never re-picked
        [[nodes objectForKey:startID] setDistance:INFINITY];

        // If we've reached the end node, break
        if ([[self lightestNodeOnGraph:duplicationNodes] isEqualToString:endID])
            break;
    }
    
    // Output the weight of the final node
    NSLog(@"Final weight of path: %i", [[nodes objectForKey:endID] distance]);
    
    // Set the start node's weight to 0, preparing it for the parsing
    [[nodes objectForKey:startID] setDistance:0];
    
    // Create an array to hold the nodes in the optimum path
    NSMutableArray *optimumPath = [[NSMutableArray alloc] init];
    
    // Set the current node in path to the end node
    KPGraphNodeItem *node = [nodes objectForKey:endID];
    
    // Loop through until we reach the start node
    while (![node.nodeTag isEqualToString:startID]) {
        
        NSLog(@"Working at node %@ with weight %i", node.nodeTag, node.distance);
        
        // Add the current node to the optimum path
        [optimumPath addObject:node.nodeTag];
        
        // Scan through all of the current node's neighbours to find
        // the next one in the path
        for (NSString *n in node.neighbours) {
            NSLog(@"%@'s neighbour %@ has weight %i and is %i away from node", node.nodeTag, n, [[nodes objectForKey:n] distance], [[node.neighbours objectForKey:n] integerValue]);
            
            // Check if this neigh our is the next in the optimum path
            // If it is, work from this node now and break from this for loop
            if ([[nodes objectForKey:n] distance] == node.distance - [[node.neighbours objectForKey:n] integerValue]) {
                node = [nodes objectForKey:n];
                break;
            }
        }
    }
    
    NSLog(@"Final path: %@", optimumPath);
    NSLog(@"Total weight: %i", [[nodes objectForKey:endID] distance]);
    
    // Add the first node to the path
    [optimumPath addObject:startID];
    
    // Reverse the path for optimum human reading
    optimumPath = [NSMutableArray arrayWithArray:[[optimumPath reverseObjectEnumerator] allObjects]];
    
    callback(optimumPath, [[nodes objectForKey:endID] distance]);
}

// Finds the distance between two given 
-(NSInteger)distanceBetween:(KPGraphNodeItem *)item1 and:(KPGraphNodeItem *)item2 forConnections:(NSMutableDictionary *)connections {
    for (NSArray *pair in connections) {

        // If the current pair are connected, return the distance
        if (([[[pair objectAtIndex:0] nodeTag] isEqualToString:item1.nodeTag] || [[[pair objectAtIndex:0] nodeTag] isEqualToString:item2.nodeTag])
            && ([[[pair objectAtIndex:1] nodeTag] isEqualToString:item1.nodeTag] || [[[pair objectAtIndex:1] nodeTag] isEqualToString:item2.nodeTag])) {
            return [(NSNumber *)[connections objectForKey:pair] integerValue];
        }
    }
    
    return INFINITY;
}

// This sorts the nodes by their weight
-(NSMutableDictionary *)sortNodes:(NSMutableDictionary *)dictionary {
    NSArray *allNodes = [dictionary allValues];

    NSArray *sortedArray = [allNodes sortedArrayUsingComparator:^NSComparisonResult(KPGraphNodeItem *item1, KPGraphNodeItem *item2) {
        return [[NSNumber numberWithInteger:item1.distance] compare:[NSNumber numberWithInteger:item2.distance]];
    }];
    
    NSMutableDictionary *sortedDict = [[NSMutableDictionary alloc] init];
    
    for (KPGraphNodeItem *item in sortedArray) {
        [sortedDict setObject:item forKey:item.nodeTag];
    }
    
    return sortedDict;
}

// Returns the lightest node on the graph. Fairly simple.
-(NSString *)lightestNodeOnGraph:(NSMutableDictionary *)includedNodes {
    NSArray *sortedArray = [includedNodes.allValues sortedArrayUsingComparator:^NSComparisonResult(KPGraphNodeItem *first, KPGraphNodeItem *second) {
        return [[NSNumber numberWithInteger:first.distance] compare:[NSNumber numberWithInteger:second.distance]];
    }];
    
    return [[includedNodes allKeysForObject:[sortedArray objectAtIndex:0]] objectAtIndex:0];
}

@end
