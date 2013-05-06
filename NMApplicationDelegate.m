#import "NMApplicationDelegate.h"
#import <CalendarStore/CalendarStore.h>
#import "CalCalendarStoreAdditions.h"
#import "CalEventAdditions.h"


@implementation NMApplicationDelegate

@synthesize statusItemMenu;
@synthesize nextEvents;
@synthesize statusItem;

#pragma mark Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsChanged:) name:CalEventsChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(updateStatusItemUI) name:NSWorkspaceDidWakeNotification object:NULL];

	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	statusItem.menu = self.statusItemMenu;
	statusItem.highlightMode = YES;
	
    [self updateEventsAndUI];
}

#pragma mark Actions

- (void)showEvent:(id)sender {
	CalEvent *event = (CalEvent *)[sender representedObject];
	[event show];	
}

#pragma mark Notifications

- (void)eventsChanged:(NSNotification *)notification {
    [self updateEventsAndUI];
}

#pragma mark Private methods

- (void)updateEventsAndUI {
	self.nextEvents = [CalCalendarStore eventsOccurringToday];
    [self updateStatusItemUI];    
}

- (void)updateStatusItemUI {
	self.statusItem.title = [self titleForNextEvent];

    // Remove old menu items
	for (NSMenuItem *item in self.statusItemMenu.itemArray) {
		if (item.tag == 0) {
            [self.statusItemMenu removeItem:item];   
        }
    }
	
    // Generate new menu items
//	for (CalEvent *event in self.nextEvents) {
//		NSMenuItem *eventMenuItem = [[NSMenuItem alloc] initWithTitle:event.title action:@selector(showEvent:) keyEquivalent:@""];
//		eventMenuItem.representedObject = event;
//		[statusItemMenu insertItem:eventMenuItem atIndex:[statusItemMenu indexOfItemWithTag:42]]; // insert above separator
//	}
	
	if (self.nextEvents.count == 0) {
		[statusItemMenu insertItemWithTitle:NSLocalizedString(@"No meetings today", nil) action:nil keyEquivalent:@"" atIndex:0];
    }
    
    // Update UI again in a minute
	[self performSelector:@selector(updateStatusItemUI) withObject:nil afterDelay:1];
}

- (NSString *)titleForNextEvent {
	NSString *title = NSLocalizedString(@"--", nil);
   
	if (self.nextEvents.count > 0) {
		CalEvent *nextEvent = [self.nextEvents objectAtIndex:0];
        
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
		NSDateComponents *components = [gregorian components:unitFlags fromDate:[NSDate date] toDate:nextEvent.startDate options:0];
		int hours = [components hour];
		int minutes = [components minute];
		int seconds = [components second];

        if ((hours == 0 && minutes >= 0) || (hours >= 0 && minutes >= 0)) {
            
            if (hours == 0 && minutes == 0) {
                if (seconds > 0) {
                    if (seconds >= 10) {
                        title = [NSString stringWithFormat:NSLocalizedString(@"0:%d", nil), seconds];
                    } else {
                        title = [NSString stringWithFormat:NSLocalizedString(@"0:0%d", nil), seconds];
                    }
                
                } else {
                    title = NSLocalizedString(@"Now!", nil);
                }
            } else if (hours == 0) {
                if (seconds >= 10) {
                    title = [NSString stringWithFormat:NSLocalizedString(@"%d:%d", nil), minutes, seconds];
                } else {
                    title = [NSString stringWithFormat:NSLocalizedString(@"%d:0%d", nil), minutes, seconds];
                }
            } else {
                NSString *minFraction = nil;
                if (hours <= 24) {
                    if (minutes >= 7 && minutes <= 22) {
                        minFraction = NSLocalizedString(@"¼", nil);
                    } else if (minutes >= 23 && minutes <= 37) {
                        minFraction = NSLocalizedString(@"½", nil);
                    } else if (minutes >= 38 && minutes <= 52) {
                        minFraction = NSLocalizedString(@"¾", nil);
                    }
                }

                if (seconds >= 10) {
                    title = [NSString stringWithFormat:@"%d:%d:%d", hours, minutes, seconds];
                } else {
                    title = [NSString stringWithFormat:@"%d:%d:0%d", hours, minutes, seconds];
                }
            }
            
            if (nextEvent.title.length) {
                title = [nextEvent.title stringByAppendingFormat:@" — %@", title];
            }
        }
	}
    
    return title;
}

@end
