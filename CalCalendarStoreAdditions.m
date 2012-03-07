/* Public domain */

#import "CalCalendarStoreAdditions.h"


@implementation CalCalendarStore (CalCalendarStoreAdditions)

+ (NSArray *)eventsOccurringToday {
    const NSTimeInterval pastHalfDayInterval = -660;
    
	CalCalendarStore *defaultStore = [self defaultCalendarStore];
	
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:pastHalfDayInterval];
    NSDate *endDate = [NSDate dateWithNaturalLanguageString:@"tomorrow at midnight"];
	NSPredicate *todayPredicate = [self eventPredicateWithStartDate:startDate endDate:endDate calendars:[defaultStore calendars]];
    
	NSArray *todaysEvents = [defaultStore eventsWithPredicate:todayPredicate];

	NSMutableArray *events = [NSMutableArray array];
    
	for (CalEvent *potentialEvent in todaysEvents) {
		if (!potentialEvent.isAllDay && [potentialEvent.startDate timeIntervalSinceDate:[NSDate date]] > pastHalfDayInterval) {
			[events addObject:potentialEvent];
        }
    }
	
	return events;
}

@end
