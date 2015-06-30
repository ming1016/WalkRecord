//
//  UILabel+ContentSize.m
//  test
//
//  Created by ming on 15/6/19.
//  Copyright (c) 2015年 ming. All rights reserved.
//

#import "UILabel+ContentSize.h"

@implementation UILabel (ContentSize)

- (CGSize)contentSize
{
    CGSize contentSize;
    if([[[UIDevice currentDevice]  systemVersion] floatValue]<= 7.0)
    {
        [self setNumberOfLines:0];
        [self setLineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,9999);
        contentSize = [[self text] sizeWithFont:[self font] constrainedToSize:maximumLabelSize lineBreakMode:[self lineBreakMode]];
    }
    else
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = self.lineBreakMode;
        paragraphStyle.alignment = self.textAlignment;
        NSDictionary * attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:paragraphStyle};
        contentSize = [self.text boundingRectWithSize:CGSizeMake(300, 99999)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil].size;
    }
    return contentSize;
}
@end
