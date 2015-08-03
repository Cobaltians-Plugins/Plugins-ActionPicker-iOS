//
//  ActionPickerPlugin.h
//  Catalog
//
//  Created by Alexandre on 09/07/2015.
//  Copyright (c) 2015 Kristal. All rights reserved.
//

#import "CobaltAbstractPlugin.h"


@interface ActionPickerPlugin : CobaltAbstractPlugin <UIActionSheetDelegate>
{
    CobaltViewController * _viewController;    
        
}

@property (nonatomic, retain) NSString * actionSheetCallback;

- (void)presentActionSheetWithActions:(NSArray *)actions
                               cancel:(NSString *)cancel
                              andText:(NSString *)text;

@end
