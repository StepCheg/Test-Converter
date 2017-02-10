//
//  ViewController.m
//  Test
//
//  Created by Stepan Chegrenev on 14.07.16.
//  Copyright © 2016 Stepan Chegrenev. All rights reserved.
//

#import "ViewController.h"
#import "ServerManager.h"

@interface ViewController ()  <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString* currentValue;   //Валюта, по отношению к которой показывают значения других валют
@property (assign, nonatomic) NSString* currentSum;     //Количество валюты currentValue
@property (strong, nonatomic) NSArray* flagsArray;      //Масив флагов
@property (strong, nonatomic) NSArray* parameters;      //Масив
@property (strong, nonatomic) NSArray* valuesSymbol;
@property (strong, nonatomic) NSMutableDictionary* valuesDictionary;    //Словарь, в котором хранятся расчитанные данные валют
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIToolbar *keyboardToolbar        = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    keyboardToolbar.backgroundColor   = [UIColor whiteColor];
    UIBarButtonItem *flexBarButton    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBarButton    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.textField action:@selector(resignFirstResponder)];
    keyboardToolbar.items             = @[flexBarButton, doneBarButton];
    self.textField.inputAccessoryView = keyboardToolbar;
    
    self.currentValue=@"USD";
    self.currentSum = @"1";
    self.valuesDictionary = [NSMutableDictionary dictionary];
    self.parameters = @[@"RUB", @"USD", @"EUR", @"GBP",  @"JPY", @"CNY", @"KRW"];
    self.valuesSymbol = @[@"₽", @"$", @"€", @"£", @"¥", @"¥", @"₩"];
    self.flagsArray = @[@"RU", @"US", @"EU", @"GB", @"JP", @"CN", @"KR"];
    
    [self getValuesFromServer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

- (void) getValuesFromServer {
    
    [[ServerManager sharedManager]
     getCurrencysValueForValue:self.currentValue
     OnSucces:^(NSDictionary *values) {
         
         NSMutableDictionary* baseValuesDictionary = [NSMutableDictionary dictionary];  // Словарь, в которм хранятся не расчитанные значения валют
         
         for (NSString* value in self.parameters) {
             NSString* rate = [values objectForKey:value];
             
             if ([values objectForKey:value] == nil) {
                 if ([self.textField.text isEqualToString:@""]) {
                     rate = self.currentSum;
                 } else {
                     self.currentSum = nil;
                     rate = self.textField.text;
                     self.currentSum = self.textField.text;
                 }
             }
             
             [baseValuesDictionary setObject:rate forKey:value];
         }
         
         for (NSString* key in [baseValuesDictionary allKeys]) {
             id object = [baseValuesDictionary objectForKey:key];
             
             double number;
             
             number = [object doubleValue];
             
             if (!(number == [self.textField.text doubleValue])) {
                 number = number * [self.currentSum doubleValue];
             }
             
             [self.valuesDictionary setObject:[NSNumber numberWithDouble:number] forKey:key];
         }
         
         NSMutableArray* newPaths = [NSMutableArray array];
         
         for (int i = 0; i < [self.valuesDictionary count]; i++) {
             [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
         }
         
         [self.tableView beginUpdates];
         [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
         
         [self.tableView endUpdates];
         
     }
     onFailure:^(NSError *error, NSInteger statuscode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statuscode);
     }];
}


#pragma mark  - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.valuesDictionary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    NSString* symbol = [self.valuesSymbol objectAtIndex:indexPath.row];
    NSString* nameOfValue = [self.parameters objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %.3f", symbol, [[self.valuesDictionary objectForKey:nameOfValue] doubleValue]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", nameOfValue];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [self.flagsArray objectAtIndex:indexPath.row]]];
    
    if (cell.selected==YES) {
        [cell setNeedsDisplay];
    }
    
    return cell;
}

#pragma mark - UITableViewDataSource

-(void) tableView :(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.valuesDictionary removeAllObjects];
    self.currentValue = [self.parameters objectAtIndex:indexPath.row];
    
    if ([self.textField.text  isEqual: @""]) {
        self.currentSum = @"1";
    }
    
    [tableView reloadData];
    [self getValuesFromServer];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range    replacementString:(NSString *)string {
    
    NSError *error;
    NSRegularExpression * regExp = [[NSRegularExpression alloc]initWithPattern:@"^\\d{0,10}(([.]\\d{1,2})|([.]))?$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString * existingText = textField.text;
    NSString * completeText = [existingText stringByAppendingFormat:@"%@",string];
    
    if ([regExp numberOfMatchesInString:completeText options:0 range:NSMakeRange(0, [completeText length])])
    {
        if ([completeText isEqualToString:@"."]){
            [textField insertText:@"0"];
        }
        return YES;
    }
    else {
        return NO;
    }
}

@end
