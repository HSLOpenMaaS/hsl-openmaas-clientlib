//
//  BuyTicketViewController.m
//  example-app-ios
//

#import "BuyTicketViewController.h"
#import "DeviceUID.h"

@interface BuyTicketViewController ()
{
    NSMutableArray *_customerTypePickerData;
    UIPickerView *_customerTypePickerView;
    
    NSMutableArray *_ticketTypePickerData;
    UIPickerView *_ticketTypePickerView;
    
    NSMutableArray *_regionTypePickerData;
    UIPickerView *_regionTypePickerView;
}
@end

@implementation BuyTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Add tap gesture recognizer to listen for taps outside of picker views.
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePickerViews:)];
    [self.view addGestureRecognizer:gesture];
    
    // Initialize picker data arrays
    _customerTypePickerData = [NSMutableArray array];
    _ticketTypePickerData = [NSMutableArray array];
    _regionTypePickerData = [NSMutableArray array];
    
    _customerTypePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    _customerTypePickerView.delegate = self;
    _customerTypePickerView.dataSource = self;
    [_customerTypePickerView setShowsSelectionIndicator:YES];
    
    _customerTypeField.inputView = _customerTypePickerView;
    _customerTypeField.delegate = self;
    
    [self fetchPickerData:_customerTypePickerData
        forPicker:_customerTypePickerView
        withEndpoint:[NSURL URLWithString:@"https://sales-api.hsl.fi/api/sandbox/ticket/v1/getCustomerTypes"]
        withParams:[NSMutableArray array]];
    
    _ticketTypePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    _ticketTypePickerView.delegate = self;
    _ticketTypePickerView.dataSource = self;
    [_ticketTypePickerView setShowsSelectionIndicator:YES];
    
    _ticketTypeField.inputView = _ticketTypePickerView;
    _ticketTypeField.delegate = self;
    
    [self fetchPickerData:_ticketTypePickerData
        forPicker:_ticketTypePickerView
        withEndpoint:[NSURL URLWithString:@"https://sales-api.hsl.fi/api/sandbox/ticket/v1/getTicketTypes"]
        withParams:[NSMutableArray array]];

    _regionTypePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    _regionTypePickerView.delegate = self;
    _regionTypePickerView.dataSource = self;
    [_regionTypePickerView setShowsSelectionIndicator:YES];
    
    _regionTypeField.inputView = _regionTypePickerView;
    _regionTypeField.delegate = self;
    
    [self fetchPickerData:_regionTypePickerData
        forPicker:_regionTypePickerView
        withEndpoint:[NSURL URLWithString:@"https://sales-api.hsl.fi/api/sandbox/ticket/v1/getRegions"]
        withParams:[NSMutableArray array]];
    
    [_buyTicketButton addTarget:self action:@selector(didTouchUp:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action events

- (void)closePickerViews:(UITapGestureRecognizer *)gesture {
    [[self view] endEditing:YES];
}

- (void)didTouchUp:(UIButton *)sender {
    [_orderTicketsActivityIndicator startAnimating];
    
    _buyTicketButton.enabled = NO;
    _buyTicketButton.alpha = 0.3;
    
    BOOL valid = [self validateFields];
    
    if (valid) {
        NSDictionary *params = [self constructParams];
        [self purchaseTicket:params];
    } else {
        [_orderTicketsActivityIndicator stopAnimating];
        
        _buyTicketButton.enabled = YES;
        _buyTicketButton.alpha = 1;
    }
}

#pragma mark - Helpers

-(BOOL)validateFields {
    // Add your validations here if needed
    return YES;
}

-(NSDictionary *)constructParams {
    NSString *clientId = @"MaaSOperatorAssignedUniqueId";
    NSString *customerTypeId = [self getIdFromArray:_customerTypePickerData withString:_customerTypeField.text];
    NSString *ticketTypeId = [self getIdFromArray:_ticketTypePickerData withString:_ticketTypeField.text];
    NSString *regionId = [self getIdFromArray:_regionTypePickerData withString:_regionTypeField.text];
    
    /*
     * VALID FROM TIMESTAMP IS NOT YET SUPPORTED.
     */
    // NSString *validFrom = @""; 
    
    /*
     * IMPORTANT!
     * GET DEVICE ID FROM [DeviceUID uid] TO BE CONSISTENT WITH REACT NATIVE IMPLEMENTATION.
     * OTHERWISE YOU MIGHT HAVE PROBLEMS WITH FETCHING AND SHOWING TICKETS.
     * REMEMBER TO IMPORT DeviceUID HEADER ON TOP OF THE FILE.
     *
     * ONLY APPLIES TO iOS.
     */
    NSString *deviceId = [DeviceUID uid]; 
    
    /* 
     * PHONE NUMBER CAN BE USED TO CHECK TICKET VALIDITY 
     * IF CUSTOMER PHONE RUNS OUT OF BATTERY WHILE TRAVELLING.
     */
    NSString *phoneNumber = @"+358 12 234 1234"; 
    
    NSArray *keys = [NSArray arrayWithObjects:
                     @"clientId",
                     @"customerTypeId",
                     @"ticketTypeId",
                     @"regionId",
                     //@"validFrom", // NOT YET SUPPORTED
                     @"deviceId",
                     @"phoneNumber",
                     nil
                     ];
    NSArray *objects = [NSArray arrayWithObjects:
                        clientId,
                        customerTypeId,
                        ticketTypeId,
                        regionId,
                        //validFrom, // NOT YET SUPPORTED
                        deviceId,
                        phoneNumber,
                        nil
                        ];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    return params;
}

-(NSString *)getIdFromArray:(NSMutableArray *)array withString:(NSString *)searchString {
    NSString *foundId = @"";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"value == %@", searchString];
    NSArray *found = [array filteredArrayUsingPredicate:predicate];
    
    for (id row in found) {
        foundId = [row objectForKey:@"id"];
        break;
    }
    
    return foundId;
}

- (void)showAlert:(NSString *)message withTitle:(NSString *)title {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismiss = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                              }];
    [alert addAction:dismiss];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - API calls

- (void)fetchPickerData:(NSMutableArray *)pickerData forPicker:(UIPickerView *)picker withEndpoint:(NSURL *)endpoint withParams:(NSArray *)params{
    NSMutableArray *newDataArray = [NSMutableArray array];
    
    NSError *error;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *contentLength = [NSString stringWithFormat:@"%lu",(unsigned long)[requestBody length]];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:endpoint];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:requestBody];
    [req setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req
        completionHandler:^(NSData *data, NSURLResponse *res, NSError *resError) {
            if (resError == nil) {
                NSDictionary* response = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:kNilOptions
                                          error:&resError];
                
                for (id row in response) {
                    NSArray *keys = [NSArray arrayWithObjects:
                                     @"id",
                                     @"value",
                                     nil
                                     ];
                    NSArray *objects = [NSArray arrayWithObjects:
                                        [row objectForKey:@"id"],
                                        [row objectForKey:@"displayName"],
                                        nil
                                        ];
                    NSDictionary *rowItem = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    [newDataArray addObject:rowItem];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [pickerData removeAllObjects];
                [pickerData addObjectsFromArray:newDataArray];
                
                if ([newDataArray count] > 0) {
                    [self pickerView: picker
                        didSelectRow:[picker selectedRowInComponent:0]
                         inComponent:0];
                }
            });
        }];
    
    [dataTask resume];
}

- (void)purchaseTicket:(NSDictionary *)params {
    /*
     * Your own server endpoint
     *
     * You need to add the X-API-Key header on your own server and probably also charge the customer before actually
     * buying the ticket from HSL API.
     *
     * To get started quickly, you can use HSL example server that can be found in GitHub /example/server folder.
     *
     * *** DO NOT *** add the API Key to your mobile app!
     */
    NSURL *orderTicketEndpoint = [NSURL URLWithString:@"http://127.0.0.1:3000/order"];
    
    NSError *error;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *contentLength = [NSString stringWithFormat:@"%lu",(unsigned long)[requestBody length]];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:orderTicketEndpoint];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:requestBody];
    [req setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req
        completionHandler:^(NSData *data, NSURLResponse *res, NSError *resError) {
            NSString *message = @"";
            NSString *title = @"";
            
            if (resError == nil) {
                NSDictionary* response = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:kNilOptions
                                          error:&resError];
                
                if ([response objectForKey:@"status"] && [[response objectForKey:@"status"] integerValue] == 200) {
                    // request successful
                    title = @"Lipun osto onnistui!";
                    message = @"Näet lippusi päivittämällä 'Omat liput' näkymän.";
                } else {
                    // request unsuccessful
                    NSLog(@"FAILED WITH MESSAGE:");
                    NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"%@",strData);
                    
                    title = @"Lipun osto epäonnistui!";
                    message = strData;
                }
            } else {
                title = @"Lipun osto epäonnistui!";
                message = resError.localizedDescription;
            }
            
            // error
            
            // Update UI
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self->_orderTicketsActivityIndicator stopAnimating];
                
                self->_buyTicketButton.enabled = YES;
                self->_buyTicketButton.alpha = 1;
                
                [self showAlert:message withTitle:title];
            });
        }];
    
    [dataTask resume];
}

#pragma mark - Delegates

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView == _customerTypePickerView) {
        return _customerTypePickerData.count;
    } else if(pickerView == _ticketTypePickerView) {
        return _ticketTypePickerData.count;
    } else if(pickerView == _regionTypePickerView) {
        return _regionTypePickerData.count;
    } else {
        return 0;
    }
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(pickerView == _customerTypePickerView) {
        return [_customerTypePickerData[row] objectForKey:@"value"];
    } else if(pickerView == _ticketTypePickerView) {
        return [_ticketTypePickerData[row] objectForKey:@"value"];
    } else if(pickerView == _regionTypePickerView) {
        return [_regionTypePickerData[row] objectForKey:@"value"];
    } else {
        return @"";
    }
}

// Handle the selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    if(pickerView == _customerTypePickerView) {
        NSDictionary *selectedValue = [_customerTypePickerData objectAtIndex:row];
        _customerTypeField.text = [selectedValue objectForKey:@"value"];
    } else if (pickerView == _ticketTypePickerView) {
        NSDictionary *selectedValue = [_ticketTypePickerData objectAtIndex:row];
        _ticketTypeField.text = [selectedValue objectForKey:@"value"];
    } else if (pickerView == _regionTypePickerView) {
        NSDictionary *selectedValue = [_regionTypePickerData objectAtIndex:row];
        _regionTypeField.text = [selectedValue objectForKey:@"value"];
    }
    
    [[self view] endEditing:YES];
}

@end
