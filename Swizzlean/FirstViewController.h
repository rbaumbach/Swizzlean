#import <UIKit/UIKit.h>


@interface FirstViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;

@property (weak, nonatomic) IBOutlet UILabel *instanceMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *instanceOutputLabel;
@property (weak, nonatomic) IBOutlet UILabel *instanceMethodCalledOutputLabel;
@property (weak, nonatomic) IBOutlet UILabel *instanceSwizzledOutputLabel;
@property (weak, nonatomic) IBOutlet UILabel *instanceSwizzledCalledOutputLabel;

@property (weak, nonatomic) IBOutlet UILabel *classMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *classOutputLabel;
@property (weak, nonatomic) IBOutlet UILabel *classMethodCalledOutputLabel;
@property (weak, nonatomic) IBOutlet UILabel *classSwizzledOutputLabel;
@property (weak, nonatomic) IBOutlet UILabel *classSwizzledCalledOutputLabel;

@end
