//
//  KPGraphNode.h
//  DijkstrasDemo
//
//  Created by Kiran Panesar on 11/02/2013.
//  Copyright (c) 2013 MobileX Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPGraphNodeView : UIView {
    UIImageView *backgroundImageView;
    UILabel *nodeTagLabel;
}

@property (strong, nonatomic) NSString *nodeTag;

-(void)showNodeAtPoint:(CGPoint)point inParentView:(UIView *)pView withTag:(NSString *)tag;

@end
