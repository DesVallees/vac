/// A utility class for calculating Colombian public holidays for a given year.
class ColombianHolidays {
  /// Returns a sorted list of all Colombian public holidays for the specified [year].
  ///
  /// This function accurately calculates both fixed and movable holidays,
  /// including those dependent on the date of Easter and those affected by
  /// Colombia's "Ley Emiliani" (which moves many holidays to the following Monday).
  static List<DateTime> getHolidays({required int year}) {
    // A Set is used to automatically handle any potential date duplicates,
    // which can occur if a holiday that is supposed to move to a Monday
    // naturally falls on a Monday.
    final Set<DateTime> holidays = {};

    // --- Easter Dependent Holidays ---
    // The calculation of several holidays depends on the date of Easter Sunday.
    final DateTime easterSunday = _calculateEasterSunday(year);

    // Maundy Thursday: The Thursday before Easter.
    holidays.add(easterSunday.subtract(const Duration(days: 3)));
    // Good Friday: The Friday before Easter.
    holidays.add(easterSunday.subtract(const Duration(days: 2)));
    // Ascension Day: 39 days after Easter Sunday, moved to the next Monday.
    holidays.add(_moveToNextMonday(easterSunday.add(const Duration(days: 39))));
    // Corpus Christi: 60 days after Easter Sunday, moved to the next Monday.
    holidays.add(_moveToNextMonday(easterSunday.add(const Duration(days: 60))));
    // Sacred Heart of Jesus: 68 days after Easter Sunday, moved to the next Monday.
    holidays.add(_moveToNextMonday(easterSunday.add(const Duration(days: 68))));

    // --- Fixed-Date Holidays That Are NOT Moved ---
    // These holidays are always celebrated on their specific date.
    holidays.add(DateTime.utc(year, 1, 1)); // New Year's Day
    holidays.add(DateTime.utc(year, 5, 1)); // Labour Day
    holidays.add(DateTime.utc(year, 7, 20)); // Independence Day
    holidays.add(DateTime.utc(year, 8, 7)); // Battle of Boyacá
    holidays.add(DateTime.utc(year, 12, 8)); // Immaculate Conception Day
    holidays.add(DateTime.utc(year, 12, 25)); // Christmas Day

    // --- Fixed-Date Holidays That ARE Moved to the Next Monday ("Ley Emiliani") ---
    // These holidays are moved to the following Monday if they don't already fall on one.
    holidays.add(_moveToNextMonday(DateTime(year, 1, 6))); // Epiphany
    holidays
        .add(_moveToNextMonday(DateTime(year, 3, 19))); // Saint Joseph's Day
    holidays.add(
        _moveToNextMonday(DateTime(year, 6, 29))); // Saint Peter and Saint Paul
    holidays
        .add(_moveToNextMonday(DateTime(year, 8, 15))); // Assumption of Mary
    holidays.add(_moveToNextMonday(DateTime(year, 10, 12))); // Columbus Day
    holidays.add(_moveToNextMonday(DateTime(year, 11, 1))); // All Saints' Day
    holidays.add(
        _moveToNextMonday(DateTime(year, 11, 11))); // Independence of Cartagena

    // Convert the Set to a List and sort it chronologically.
    final List<DateTime> sortedHolidays = holidays.toList();
    sortedHolidays.sort();

    return sortedHolidays;
  }

  /// Calculates the date of Easter Sunday for a given [year] using the
  /// anonymous Gregorian algorithm (also known as the Meeus/Jones/Butcher algorithm).
  static DateTime _calculateEasterSunday(int year) {
    final int a = year % 19;
    final int b = year ~/ 100;
    final int c = year % 100;
    final int d = b ~/ 4;
    final int e = b % 4;
    final int f = (b + 8) ~/ 25;
    final int g = (b - f + 1) ~/ 3;
    final int h = (19 * a + b - d - g + 15) % 30;
    final int i = c ~/ 4;
    final int k = c % 4;
    final int l = (32 + 2 * e + 2 * i - h - k) % 7;
    final int m = (a + 11 * h + 22 * l) ~/ 451;

    final int month = (h + l - 7 * m + 114) ~/ 31;
    final int day = ((h + l - 7 * m + 114) % 31) + 1;

    return DateTime.utc(year, month, day);
  }

  /// Moves the given [date] to the following Monday if it is not already a Monday.
  /// This implements the "Ley Emiliani" for Colombian holidays.
  static DateTime _moveToNextMonday(DateTime rawDate) {
    // Normalize the date to midnight UTC to prevent timezone-related bugs.
    final date = DateTime.utc(rawDate.year, rawDate.month, rawDate.day);

    // DateTime.monday == 1 ... DateTime.sunday == 7
    if (date.weekday == DateTime.monday) {
      return date;
    } else {
      // Calculate days to add to get to the next Monday.
      // (8 - weekday) gives the correct offset.
      // e.g., if it's a Tuesday (2), 8 - 2 = 6 days to add.
      // e.g., if it's a Sunday (7), 8 - 7 = 1 day to add.
      return date.add(Duration(days: 8 - date.weekday));
    }
  }
}
