/*
 
 Copyright (C) 2013-2015, Patrick Jayet
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
*/

#import "ConfigureReportController.h"
#import "SelectDayController.h"


@interface ConfigureReportController ()

@property (weak, nonatomic) IBOutlet UITextField *startDateField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (strong, nonatomic) NSArray* periodicityNbs;
@property (strong, nonatomic) NSArray* periodicityUnits;

@property (strong, nonatomic) NSDateFormatter* dateFormatter;

@end


@implementation ConfigureReportController

#pragma mark methods from UIPickerView (DataSource and Delegate)

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.periodicityNbs count];
    }
    else {
        return [self.periodicityUnits count];
    }
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [NSString stringWithFormat:@"%@", [self.periodicityNbs objectAtIndex:row]];
    }
    else {
        return [NSString stringWithFormat:@"%@(s)", [self.periodicityUnits objectAtIndex:row]];
    }
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.periodicityNb = [self.periodicityNbs[row] integerValue];
    }
    else /* component == 1 */ {
        self.periodicityUnit = self.periodicityUnits[row];
    }
}

#pragma mark custom methods

- (void)updateDateField
{
    self.startDateField.text = [self.dateFormatter stringFromDate:self.periodStart];
}

- (void)updatePickerView
{
    NSUInteger nbIndex = [self.periodicityNbs indexOfObject:[NSNumber numberWithInteger:self.periodicityNb]];
    NSUInteger unitIndex = [self.periodicityUnits indexOfObject:self.periodicityUnit];
    [self.pickerView selectRow:nbIndex inComponent:0 animated:NO];
    [self.pickerView selectRow:unitIndex inComponent:1 animated:NO];
}

#pragma mark methods from UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChooseStartDate"]) {
        SelectDayController* controller = (SelectDayController*) segue.destinationViewController;
        controller.currentDate = self.periodStart;
    }
}

- (IBAction)doneSelectingDay:(UIStoryboardSegue *)segue
{
    NSLog(@"Done selecting day");
    
    SelectDayController* sourceController = segue.sourceViewController;
    self.periodStart = sourceController.currentDate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.periodicityNbs   = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    self.periodicityUnits = @[@"day", @"week", @"month"];
    
    [self updatePickerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateDateField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
