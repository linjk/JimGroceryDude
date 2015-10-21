//
//  PrepareTVC.h
//  JimGroceryDude
//
//  Created by hodi on 10/21/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import "CoreDataTVC.h"

@interface PrepareTVC : CoreDataTVC <UIActionSheetDelegate>

@property (nonatomic, strong) UIActionSheet *clearConfirmActionSheet;//防止用户点击全部清除清单的货品，弹出确定

@end
