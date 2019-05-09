//
//  segmentedControl.m
//  CustomGallery
//
//  Created by leo on 6/5/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//

#import "segmentedControl.h"

@implementation segmentedControl

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder ];
    [self designSegmentBar];
    return self;
}
-(void) designSegmentBar
{
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:14*([UIScreen mainScreen].bounds.size.width/414)] , NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                nil];
    [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self  setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    self.layer.cornerRadius = 2 ;
    self.layer.borderColor = [UIColor colorWithRed:77.0f/255.0f
                                             green:77.0f/255.0f
                                              blue:77.0f/255.0f
                                             alpha:1.0f].CGColor;
    self.layer.borderWidth =1.3f;
}
@end
