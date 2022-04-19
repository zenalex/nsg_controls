import 'package:jiffy/jiffy.dart';
import 'package:nsg_controls/components/nsg_data_format.dart';

class NsgPeriodType {
  final int type;
  NsgPeriodType(this.type);
  static NsgPeriodType year = NsgPeriodType(1);
  static NsgPeriodType quarter = NsgPeriodType(2);
  static NsgPeriodType month = NsgPeriodType(3);
  static NsgPeriodType week = NsgPeriodType(4);
  static NsgPeriodType day = NsgPeriodType(5);
  static NsgPeriodType period = NsgPeriodType(6);
  static NsgPeriodType periodWidthTime = NsgPeriodType(7);
}

class NsgPeriod {
  DateTime endDate = DateTime.now();
  DateTime beginDate = Jiffy(DateTime.now()).subtract(months: 3).dateTime;
  String dateText = '';
  NsgPeriodType type = NsgPeriodType.year;

  void plus() {
    switch (type.type) {
      case 1:
        beginDate = Jiffy(beginDate).add(years: 1).dateTime;
        endDate = Jiffy(beginDate).add(years: 1).dateTime;
        break;
      case 2:
        beginDate = Jiffy(beginDate).add(months: 3).dateTime;
        endDate = Jiffy(beginDate).add(months: 3).dateTime;
        break;
      case 3:
        beginDate = Jiffy(beginDate).add(months: 1).dateTime;
        endDate = Jiffy(beginDate).add(months: 1).dateTime;
        break;
      case 4:
        beginDate = Jiffy(beginDate).add(days: 7).dateTime;
        endDate = Jiffy(beginDate).add(days: 7).dateTime;
        break;
      case 5:
        beginDate = Jiffy(beginDate).add(days: 1).dateTime;
        endDate = Jiffy(beginDate).add(days: 1).dateTime;
        break;
      case 6:
        beginDate = Jiffy(beginDate).add(days: 1).dateTime;
        endDate = Jiffy(beginDate).add(days: 1).dateTime;
        break;
      case 7:
        beginDate = Jiffy(beginDate).add(days: 1).dateTime;
        endDate = Jiffy(beginDate).add(days: 1).dateTime;
        break;

      default:
        print("добавление - ошибка");
    }
  }

  void minus() {
    switch (type.type) {
      case 1:
        beginDate = Jiffy(beginDate).subtract(years: 1).dateTime;
        endDate = Jiffy(beginDate).subtract(years: 1).dateTime;
        break;
      case 2:
        beginDate = Jiffy(beginDate).subtract(months: 3).dateTime;
        endDate = Jiffy(beginDate).subtract(months: 3).dateTime;
        break;
      case 3:
        beginDate = Jiffy(beginDate).subtract(months: 1).dateTime;
        endDate = Jiffy(beginDate).subtract(months: 1).dateTime;
        break;
      case 4:
        beginDate = Jiffy(beginDate).subtract(days: 7).dateTime;
        endDate = Jiffy(beginDate).subtract(days: 7).dateTime;
        break;
      case 5:
        beginDate = Jiffy(beginDate).subtract(days: 1).dateTime;
        endDate = Jiffy(beginDate).subtract(days: 1).dateTime;
        break;
      case 6:
        beginDate = Jiffy(beginDate).subtract(days: 1).dateTime;
        endDate = Jiffy(beginDate).subtract(days: 1).dateTime;
        break;
      case 7:
        beginDate = Jiffy(beginDate).subtract(days: 1).dateTime;
        endDate = Jiffy(beginDate).subtract(days: 1).dateTime;
        break;

      default:
        print("добавление - ошибка");
    }
  }

  void setDateText() {
    switch (type.type) {
      case 1:
        dateText = NsgDateFormat.dateFormat(beginDate, 'yyyy г.');
        break;
      case 2:
        dateText = NsgDateFormat.dateFormat(beginDate, getKvartal(beginDate).toString() + ' квартал yyyy г.');
        break;
      case 3:
        dateText = NsgDateFormat.dateFormat(beginDate, 'MMM yyyy г.');
        break;
      case 4:
        dateText = NsgDateFormat.dateFormat(beginDate, 'd MMM yy - ') + NsgDateFormat.dateFormat(endDate, 'd MMM yy');
        break;
      case 5:
        dateText = NsgDateFormat.dateFormat(beginDate, 'd MMMM yyyy г.');
        break;
      case 6:
        dateText = NsgDateFormat.dateFormat(beginDate, 'd MMM yy - ') + NsgDateFormat.dateFormat(endDate, 'd MMM yy');
        break;
      case 7:
        dateText = NsgDateFormat.dateFormat(beginDate, 'd MMM yy - ') + NsgDateFormat.dateFormat(endDate, 'd MMM yy');
        break;

      default:
        print("добавление - ошибка");
    }
  }

  void setToYear(DateTime date) {
    beginDate = DateTime(date.year);
    endDate = Jiffy(DateTime(date.year)).add(years: 1).dateTime;
    type = NsgPeriodType.year;
    setDateText();
  }

  void setToQuarter(DateTime date) {
    beginDate = Jiffy(DateTime(date.year)).add(months: (getKvartal(date) - 1) * 3).dateTime;
    endDate = Jiffy(beginDate).add(months: 3).dateTime.subtract(const Duration(microseconds: 1));
    type = NsgPeriodType.quarter;
    setDateText();
  }

  void setToMonth(DateTime date) {
    beginDate = DateTime(date.year, date.month);
    endDate = Jiffy(beginDate).add(months: 1).dateTime.subtract(const Duration(microseconds: 1));
    type = NsgPeriodType.month;
    setDateText();
  }

  void setToWeek(DateTime date) {
    beginDate = dateZeroTime(date).subtract(Duration(days: date.weekday - 1));
    endDate = beginDate.add(const Duration(days: 7)).subtract(const Duration(microseconds: 1));
    type = NsgPeriodType.week;
    setDateText();
  }

  void setToDay(DateTime date) {
    beginDate = dateZeroTime(date);
    endDate = beginDate;
    type = NsgPeriodType.day;
    setDateText();
  }

  void setToPeriod(NsgPeriod date) {
    beginDate = dateZeroTime(date.beginDate);
    endDate = dateZeroTime(date.endDate);
    type = NsgPeriodType.period;
    setDateText();
  }

  void setToPeriodWithTime(NsgPeriod date) {
    beginDate = date.beginDate;
    endDate = date.endDate;
    type = NsgPeriodType.periodWidthTime;
    setDateText();
  }

  DateTime dateZeroTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  int getKvartal(DateTime date) {
    int kvartal = (date.month / 3).ceil();
    return kvartal;
  }
}
