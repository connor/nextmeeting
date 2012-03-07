/* Public domain */

#import <Cocoa/Cocoa.h>


@interface NMApplicationDelegate : NSObject

@property (nonatomic) IBOutlet NSMenu *statusItemMenu;
@property (nonatomic) NSArray *nextEvents;
@property (nonatomic) NSStatusItem *statusItem;

@end
