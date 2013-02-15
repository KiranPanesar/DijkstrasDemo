//
//  KPGraphCanvasView.m
//  DijkstrasDemo
//
//  Created by Kiran Panesar on 11/02/2013.
//  Copyright (c) 2013 MobileX Labs. All rights reserved.
//

#import "KPGraphCanvasView.h"
#import "KPGraphNodeView.h"

#define NODE_PARING(node1, node2) [NSArray arrayWithObjects:node1, node2, nil]

static NSString * letters[] = {@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"};

@implementation KPGraphCanvasView

-(void)showRouteBetweenFinalNodes:(NSMutableDictionary *)finalNodes {    
    finalParings = [[NSMutableDictionary alloc] initWithDictionary:finalNodes];
    
    [self setNeedsDisplay];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [firstTappedNode setBackgroundColor:[UIColor clearColor]];
    [secondTappedNode setBackgroundColor:[UIColor clearColor]];

    finalParings = nil;

    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Add Arc"]) {
        NSInteger weight = [[[alertView textFieldAtIndex:0] text] integerValue];
        if (weight > 0) {
            [self.nodeParings setObject:[NSNumber numberWithInteger:weight] forKey:NODE_PARING(firstTappedNode, secondTappedNode)];
            [self setNeedsDisplay];
        } else {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Could Not Add Arc"
                                                                 message:@"Please enter a valid weight"
                                                                delegate:nil
                                                       cancelButtonTitle:@"Dismiss"
                                                       otherButtonTitles:nil, nil];
            [errorAlert show];
        }

    } else {
        firstTappedNode = [[KPGraphNodeView alloc] init];
        secondTappedNode = [[KPGraphNodeView alloc] init];

    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.addingNode) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        
        KPGraphNodeView *node = [[KPGraphNodeView alloc] init];
        [node setUserInteractionEnabled:YES];
        
        NSString *nodeTag;
        
        // If the node requires a 2-char name
        if ([self.graphNodes count] > 25) {
            NSInteger scale = floor([self.graphNodes count] / 26);
            NSString *firstChar = letters[scale-1];
            NSString *secondChar = letters[[self.graphNodes count] - (scale * 26)];

            nodeTag = [NSString stringWithFormat:@"%@%@", firstChar, secondChar];
            
        } else {
            nodeTag = letters[[self.graphNodes count]];
        }
        
        [node showNodeAtPoint:touchLocation inParentView:self withTag:nodeTag];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedNode:)];
        [node addGestureRecognizer:tapGesture];
        
        [self.graphNodes addObject:node];
        self.addingNode = FALSE;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([[touch view] isKindOfClass:[KPGraphNodeView class]]) {
        CGPoint touchLocation = [touch locationInView:self];
        if (CGRectContainsPoint(self.bounds, touchLocation)) {
            [[touch view] setCenter:touchLocation];
            [self setNeedsDisplay];
        }
    }
}

-(void)selectedNode:(id)gesture {    
    if ([[firstTappedNode nodeTag] length] > 0 && ![[firstTappedNode nodeTag] isEqualToString:[(KPGraphNodeView *)[gesture view] nodeTag]]) {
        secondTappedNode = (KPGraphNodeView *)[gesture view];
        
        UIAlertView *nodeDistanceAlert = [[UIAlertView alloc] initWithTitle:@"Set Arc Weight"
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@"Add Arc", nil];

        [nodeDistanceAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[nodeDistanceAlert textFieldAtIndex:0] setPlaceholder:[NSString stringWithFormat:@"Enter Weight Between %@ and %@", firstTappedNode.nodeTag, secondTappedNode.nodeTag]];
        [[nodeDistanceAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [nodeDistanceAlert show];
        
    } else if ([[firstTappedNode nodeTag] isEqualToString:[(KPGraphNodeView *)[gesture view] nodeTag]]) {
        [firstTappedNode setBackgroundColor:[UIColor clearColor]];
        
        firstTappedNode = [[KPGraphNodeView alloc] init];
        secondTappedNode = [[KPGraphNodeView alloc] init];
    } else {
        firstTappedNode = [[KPGraphNodeView alloc] init];
        secondTappedNode = [[KPGraphNodeView alloc] init];
        
        firstTappedNode = (KPGraphNodeView *)[gesture view];
        [firstTappedNode setBackgroundColor:[UIColor redColor]];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    for (id view in [self subviews]) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    for (int i = 0; i < [self.nodeParings count]; i++) {
        NSArray *parings = [[self.nodeParings allKeys] objectAtIndex:i];
        NSNumber *weight = [self.nodeParings objectForKey:parings];
                
        KPGraphNodeView *nodeOne = [parings objectAtIndex:0];
        KPGraphNodeView *nodeTwo = [parings objectAtIndex:1];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        
        // if the route has already been found, highlight the optimum route in bold green
        if (finalParings) {
            for (NSArray *finalPair in finalParings) {
                if (([[nodeOne nodeTag] isEqualToString:[finalPair objectAtIndex:0]] && [[nodeTwo nodeTag] isEqualToString:[finalPair objectAtIndex:1]])
                    || ([[nodeOne nodeTag] isEqualToString:[finalPair objectAtIndex:1]] && [[nodeTwo nodeTag] isEqualToString:[finalPair objectAtIndex:0]])) {
                    CGContextSetStrokeColorWithColor(context, [[UIColor greenColor]CGColor]);
                    CGContextSetLineWidth(context, 5.0);
                }
            }
        } else {
            // If not, just make the line thin, black.
            CGContextSetStrokeColorWithColor(context, [[UIColor blackColor]CGColor]);
            CGContextSetLineWidth(context, 1.0);
        }
        
        CGContextMoveToPoint(context, nodeOne.center.x, nodeOne.center.y);
        CGContextAddLineToPoint(context, nodeTwo.center.x, nodeTwo.center.y);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        
        
        CGSize textSize = [[NSString stringWithFormat:@"%@", weight] sizeWithFont:[UIFont systemFontOfSize:15.0f]];

        UILabel *weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, textSize.width, textSize.height)];
        [weightLabel setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
        [weightLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [weightLabel setText:[NSString stringWithFormat:@"%@", weight]];
        
        float xPoint = (nodeOne.center.x + nodeTwo.center.x)/2;
        float yPoint = (nodeOne.center.y + nodeTwo.center.y)/2;
        [weightLabel setCenter:CGPointMake(xPoint, yPoint)];
        
        [self addSubview:weightLabel];
    }
        
    firstTappedNode = nil;
    secondTappedNode = nil;
}

@end
