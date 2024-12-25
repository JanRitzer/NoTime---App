import Foundation

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day ?? 0
    }
    
    func combine(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var fullComponents = DateComponents()
        fullComponents.year = dateComponents.year
        fullComponents.month = dateComponents.month
        fullComponents.day = dateComponents.day
        fullComponents.hour = timeComponents.hour
        fullComponents.minute = timeComponents.minute
        
        return calendar.date(from: fullComponents)
    }
    
    func timeUntil(from: Date, to: Date) -> (days: Int, hours: Int, minutes: Int) {
        let components = dateComponents([.day, .hour, .minute], from: from, to: to)
        return (
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0
        )
    }
} 