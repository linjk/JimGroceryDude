//
//  CoreDataPickerTF.m
//  JimGroceryDude
//
//  Created by hodi on 10/22/15.
//  Copyright © 2015 LinJK. All rights reserved.
//

#import "CoreDataPickerTF.h"

@implementation CoreDataPickerTF
#define debug 1

#pragma mark DELEGATE+DATASOURCE: UIPickerView
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickerData count];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44.0f;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 280.0f;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.pickerData objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSManagedObject *object = [self.pickerData objectAtIndex:row];
    [self.pickerDelegate selectedObjectID:object.objectID changedForPickerTF:self];
}

#pragma mark INTERACTION
-(void)done{
    [self resignFirstResponder];
}

-(void)clear{
    [self.pickerDelegate selectedObjectClearedForPickerTF:self];
    [self resignFirstResponder];
}

#pragma mark DATA
//子类必须覆盖下面两个方法
-(void)fetch{
    [NSException raise:NSInternalInconsistencyException format:@"You must override the '%@' method to provide data to the picker.", NSStringFromSelector(_cmd)];
}

-(void)selectDefaultRow{
    [NSException raise:NSInternalInconsistencyException format:@"You must override the '%@' method to set the default picker row", NSStringFromSelector(_cmd)];
}

#pragma mark VIEW
-(UIView *)createInputView{
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.picker.showsSelectionIndicator = YES;
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.picker.dataSource = self;
    self.picker.delegate = self;
    [self fetch];
    
    return self.picker;
}

-(UIView *)createIpnutAccessoryView{
    if (!self.toolbar && self.showToolbar) {
        self.toolbar = [[UIToolbar alloc] init];
        self.toolbar.barStyle = UIBarStyleBlackTranslucent;
        self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.toolbar sizeToFit];
        
        CGRect frame = self.toolbar.frame;
        frame.size.height = 44.0f;
        self.toolbar.frame = frame;
        
        UIBarButtonItem *clearBtn = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        
        NSArray *array = [NSArray arrayWithObjects:clearBtn, spacer, doneBtn,nil];
        [self.toolbar setItems:array];
    }
    
    return self.toolbar;
}

-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.inputView = [self createInputView];
        self.inputAccessoryView = [self createIpnutAccessoryView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        self.inputView = [self createInputView];
        self.inputAccessoryView = [self createIpnutAccessoryView];
    }
    return self;
}

-(void)deviceDidRotate:(NSNotification *)notification{
    [self.picker setNeedsLayout];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
