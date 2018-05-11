//
//  BuyTicketViewController.h
//  example-app-ios
//

#import <UIKit/UIKit.h>

@interface BuyTicketViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *customerTypeField;
@property (weak, nonatomic) IBOutlet UITextField *ticketTypeField;
@property (weak, nonatomic) IBOutlet UITextField *regionTypeField;

@property (weak, nonatomic) IBOutlet UIButton *buyTicketButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *orderTicketsActivityIndicator;

@end
