//
//  ActionPickerPlugin.m
//  Catalog
//
//  Created by Alexandre on 09/07/2015.
//  Copyright (c) 2015 Kristal. All rights reserved.
//

#import "ActionPickerPlugin.h"
#import <Cobalt/PubSub.h>

@implementation ActionPickerPlugin

- (void)onMessageFromWebView:(WebViewType)webView
          inCobaltController:(nonnull CobaltViewController *)viewController
                  withAction:(nonnull NSString *)action
                        data:(nullable NSDictionary *)data
          andCallbackChannel:(nullable NSString *)callbackChannel
{
    if ([action isEqualToString:@"getAction"]
        && callbackChannel != nil)
    {
        NSArray * actions = [data objectForKey:@"actions"];
        NSString * cancel = [data objectForKey:@"cancel"];
        NSString * text = [data objectForKey: @"text"];
        
        if (actions != nil && [actions isKindOfClass:[NSArray class]]
            && cancel != nil && [cancel isKindOfClass:[NSString class]]) {
            _actionSheetCallback = callbackChannel;
            _viewController = viewController;
            [self presentActionSheetWithActions:actions
                                         cancel:cancel
                                        andText:text];

        }
    }
}

- (void)presentActionSheetWithActions:(NSArray *)actions
                               cancel:(NSString *)cancel
                              andText:(NSString *)text {
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare: @"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        UIAlertController *actionSheet = [UIAlertController
                                          alertControllerWithTitle:text
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:cancel
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action){
                                                                  NSDictionary * data = @{@"index": @(-1)};
                                                                  [[PubSub sharedInstance] publishMessage:data
                                                                                                toChannel:_actionSheetCallback];
                                                                  _actionSheetCallback = nil;
                                                              }];
        [actionSheet addAction:cancelAction];
        
        NSUInteger actionsCount = [actions count];
        for (int i = 0 ; i < actionsCount ; i++) {
            UIAlertAction * otherAction = [UIAlertAction actionWithTitle:[actions objectAtIndex:i]
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action)
                                           {
                                               NSDictionary * data = @{@"index": @(i)};
                                               [[PubSub sharedInstance] publishMessage: data
                                                                             toChannel:_actionSheetCallback];
                                               _actionSheetCallback = nil;
                                           }];
            [actionSheet addAction:otherAction];
        }
        UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
        if (popover)
        {
            popover.sourceView = _viewController.view;
            popover.sourceRect = CGRectMake(([UIScreen mainScreen].bounds.size.width)/2, ([UIScreen mainScreen].bounds.size.height)/2, 1, 1);
            popover.permittedArrowDirections = 0;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_viewController presentViewController:actionSheet
                                         animated:YES
                                       completion:nil];
        });
    }else{
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle: text
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:nil];
        
        NSUInteger actionsCount = [actions count];
        for (int i = 0 ; i < actionsCount ; i++) {
            [actionSheet addButtonWithTitle:[actions objectAtIndex:i]];
        }
        
        [actionSheet addButtonWithTitle:cancel];
        [actionSheet setCancelButtonIndex:actionsCount];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                
                [actionSheet showInView: _viewController.view];
                
            }
            else {
                if(_viewController.navigationController.toolbarHidden)
                    [actionSheet showInView: _viewController.view];
                else
                    [actionSheet showFromToolbar: _viewController.navigationController.toolbar];
            }
            
        });
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDictionary *data = nil;
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        data = @{@"index": @(-1)};
    }
    else {
        data = @{@"index": @(buttonIndex)};
    }
    
    [[PubSub sharedInstance] publishMessage: data
                                  toChannel:_actionSheetCallback];
    _actionSheetCallback = nil;
}

@end
