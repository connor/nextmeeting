/* Public domain */

#import "CalEventAdditions.h"
#import "Calendar.h"


@implementation CalEvent (CalEventAdditions)

- (void)show {
	CalendarApplication *calendarApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iCal"];
	[calendarApp activate];
	
	NSArray *matchingCalendars = [[calendarApp calendars] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", self.calendar.uid]];
    
	if (matchingCalendars.count > 0) {
		CalendarCalendar *containingCalendar = [matchingCalendars lastObject];
		NSArray *matchingEvents = [[containingCalendar events] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", self.uid]];
        
		if (matchingEvents.count > 0) {
			[[matchingEvents lastObject] show];
        }
	}
}

@end
