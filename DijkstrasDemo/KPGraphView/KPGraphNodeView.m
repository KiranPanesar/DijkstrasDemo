//
//  KPGraphNode.m
//  DijkstrasDemo
//
//  Created by Kiran Panesar on 11/02/2013.
//  Copyright (c) 2013 MobileX Labs. All rights reserved.
//

#import "KPGraphNodeView.h"

@implementation KPGraphNodeView

-(id)init {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 40.0f)];
    if (self) {
        
    }
    return self;
}

-(void)showNodeAtPoint:(CGPoint)point inParentView:(UIView *)pView withTag:(NSString *)tag {
    [self setCenter:point];
    
    backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 30.0f, 30.0f)];
    [backgroundImageView setImage:[UIImage imageNamed:@"node_background"]];
    [self addSubview:backgroundImageView];
    
    CGSize textSize = [tag sizeWithFont:[UIFont boldSystemFontOfSize:15.0f]];
    nodeTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, textSize.width, textSize.height)];
    [nodeTagLabel setTextAlignment:NSTextAlignmentCenter];
    [nodeTagLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [nodeTagLabel setText:tag];
    [nodeTagLabel setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:.5]];

    self.nodeTag = tag;
    
    [self addSubview:nodeTagLabel];
    
    [pView addSubview:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
