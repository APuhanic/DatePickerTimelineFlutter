import 'package:date_picker_timeline/gregorian_date/gregorian_date_widget.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/style.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:date_picker_timeline/persian_date/persian_date.dart';
import 'package:date_picker_timeline/persian_date/persian_date_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

part 'date_type.dart';

class DatePicker extends StatefulWidget {
  /// Start Date in case user wants to show past dates
  final DateTime startDate;

  /// Width of the selector
  final double width;

  /// Height of the selector
  final double height;

  /// DatePicker Controller
  final DatePickerController? controller;

  /// Text color for the selected Date
  final Color selectedTextColor;

  /// Background color for the selector
  final Color selectionColor;

  /// Text Color for the deactivated dates
  final Color deactivatedColor;

  /// TextStyle for Month Value
  final TextStyle monthTextStyle;

  /// TextStyle for day Value
  final TextStyle dayTextStyle;

  /// TextStyle for the date Value
  final TextStyle dateTextStyle;

  /// Contains the list of inactive dates.
  final List<DateTime>? inactiveDates;

  /// Contains the list of active dates.
  final List<DateTime>? activeDates;

  /// Callback function for when a different date is selected
  final DateChangeListener? onDateChange;

  /// Max limit up to which the dates are shown
  final int daysCount;

  /// Calendar type
  final CalendarType calendarType;

  /// Directionality
  final TextDirection? directionality;

  /// Locale for the calendar default: en_us
  final String locale;

  DatePicker(
    this.startDate, {
    Key? key,
    this.width = 60,
    this.height = 80,
    this.controller,
    this.monthTextStyle = defaultMonthTextStyle,
    this.dayTextStyle = defaultDayTextStyle,
    this.dateTextStyle = defaultDateTextStyle,
    this.selectedTextColor = Colors.white,
    this.selectionColor = AppColors.defaultSelectionColor,
    this.deactivatedColor = AppColors.defaultDeactivatedColor,
    this.inactiveDates,
    this.activeDates,
    this.daysCount = 500,
    this.onDateChange,
    this.locale = "en_US",
    this.calendarType = CalendarType.gregorianDate,
    this.directionality,
  }) : assert(activeDates == null || inactiveDates == null,
            "Can't provide both activated and deactivated dates List at the same time.");

  @override
  State<StatefulWidget> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? _currentDate;

  final ScrollController _controller = ScrollController();

  late final TextStyle selectedDateStyle;
  late final TextStyle selectedMonthStyle;
  late final TextStyle selectedDayStyle;

  late final TextStyle deactivatedDateStyle;
  late final TextStyle deactivatedMonthStyle;
  late final TextStyle deactivatedDayStyle;

  @override
  void initState() {
    // Init the calendar locale
    initializeDateFormatting(widget.locale, null);

    // No initial selected date
    _currentDate = null;

    widget.controller?.setDatePickerState(this);

    selectedDateStyle =
        widget.dateTextStyle.copyWith(color: widget.selectedTextColor);
    selectedMonthStyle =
        widget.monthTextStyle.copyWith(color: widget.selectedTextColor);
    selectedDayStyle =
        widget.dayTextStyle.copyWith(color: widget.selectedTextColor);

    deactivatedDateStyle =
        widget.dateTextStyle.copyWith(color: widget.deactivatedColor);
    deactivatedMonthStyle =
        widget.monthTextStyle.copyWith(color: widget.deactivatedColor);
    deactivatedDayStyle =
        widget.dayTextStyle.copyWith(color: widget.deactivatedColor);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.directionality ??
          (widget.calendarType == CalendarType.persianDate
              ? TextDirection.rtl
              : TextDirection.ltr),
      child: Container(
        height: widget.height,
        child: ListView.builder(
          itemCount: widget.daysCount,
          scrollDirection: Axis.horizontal,
          controller: _controller,
          itemBuilder: (context, index) {
            // get the date object based on the index position
            DateTime date;
            DateTime _date = widget.startDate.add(Duration(days: index));
            switch (widget.calendarType) {
              case CalendarType.persianDate:
                date = PersianDate.toJalali(_date.year, _date.month, _date.day);
                break;
              case CalendarType.gregorianDate:
                date = DateTime(_date.year, _date.month, _date.day);
                break;
              default:
                date = DateTime(_date.year, _date.month, _date.day);
            }

            bool isDeactivated = false;

            // check if this date needs to be deactivated for DeactivatedDates
            if (widget.inactiveDates != null) {
              for (DateTime inactiveDate in widget.inactiveDates!) {
                if (DateUtils.isSameDay(date, inactiveDate)) {
                  isDeactivated = true;
                  break;
                }
              }
            }

            // check if this date needs to be deactivated for ActivatedDates
            if (widget.activeDates != null) {
              isDeactivated = true;
              for (DateTime activateDate in widget.activeDates!) {
                if (DateUtils.isSameDay(date, activateDate)) {
                  isDeactivated = false;
                  break;
                }
              }
            }

            // Check if this date is the one that is currently selected
            bool isSelected = _currentDate != null
                ? DateUtils.isSameDay(date, _currentDate!)
                : false;

            // Return the Date Widget
            switch (widget.calendarType) {
              case CalendarType.gregorianDate:
                return GregorianDateWidget(
                  date: date,
                  monthTextStyle: isDeactivated
                      ? deactivatedMonthStyle
                      : isSelected
                          ? selectedMonthStyle
                          : widget.monthTextStyle,
                  dateTextStyle: isDeactivated
                      ? deactivatedDateStyle
                      : isSelected
                          ? selectedDateStyle
                          : widget.dateTextStyle,
                  dayTextStyle: isDeactivated
                      ? deactivatedDayStyle
                      : isSelected
                          ? selectedDayStyle
                          : widget.dayTextStyle,
                  width: widget.width,
                  locale: widget.locale,
                  selectionColor:
                      isSelected ? widget.selectionColor : Colors.transparent,
                  onDateSelected: (selectedDate) {
                    if (isDeactivated) return;

                    setState(() {
                      _currentDate = isSelected ? null : selectedDate;
                    });

                    // Notify listener with the current date (can be null)
                    widget.onDateChange?.call(_currentDate);
                  },
                );
              case CalendarType.persianDate:
                return PersianDateWidget(
                  date: date,
                  monthTextStyle: isDeactivated
                      ? deactivatedMonthStyle
                      : isSelected
                          ? selectedMonthStyle
                          : widget.monthTextStyle,
                  dateTextStyle: isDeactivated
                      ? deactivatedDateStyle
                      : isSelected
                          ? selectedDateStyle
                          : widget.dateTextStyle,
                  dayTextStyle: isDeactivated
                      ? deactivatedDayStyle
                      : isSelected
                          ? selectedDayStyle
                          : widget.dayTextStyle,
                  width: widget.width,
                  locale: widget.locale,
                  selectionColor:
                      isSelected ? widget.selectionColor : Colors.transparent,
                  onDateSelected: (selectedDate) {
                    if (isDeactivated) return;

                    // Check if the same date is clicked again to deselect it
                    setState(() {
                      if (isSelected) {
                        _currentDate = null;
                      } else {
                        _currentDate = selectedDate;
                      }
                    });

                    // Notify listener if a different date is selected or deselected
                    widget.onDateChange?.call(_currentDate!);
                  },
                );
            }
          },
        ),
      ),
    );
  }
}

class DatePickerController {
  _DatePickerState? _datePickerState;

  void setDatePickerState(_DatePickerState state) {
    _datePickerState = state;
  }

  void jumpToSelection() {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    // jump to the current Date
    _datePickerState!._controller
        .jumpTo(_calculateDateOffset(_datePickerState!._currentDate!));
  }

  /// This function will animate the Timeline to the currently selected Date
  void animateToSelection(
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    // animate to the current date
    _datePickerState!._controller.animateTo(
        _calculateDateOffset(_datePickerState!._currentDate!),
        duration: duration,
        curve: curve);
  }

  /// This function will animate to any date that is passed as an argument
  /// In case a date is out of range nothing will happen
  void animateToDate(DateTime date,
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    _datePickerState!._controller.animateTo(_calculateDateOffset(date),
        duration: duration, curve: curve);
  }

  /// This function will animate to any date that is passed as an argument
  /// this will also set that date as the current selected date
  void setDateAndAnimate(DateTime date,
      {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_datePickerState != null,
        'DatePickerController is not attached to any DatePicker View.');

    _datePickerState!._controller.animateTo(_calculateDateOffset(date),
        duration: duration, curve: curve);

    if (date.compareTo(_datePickerState!.widget.startDate) >= 0 &&
        date.compareTo(_datePickerState!.widget.startDate
                .add(Duration(days: _datePickerState!.widget.daysCount))) <=
            0) {
      // date is in the range
      _datePickerState!._currentDate = date;
    }
  }

  /// Calculate the number of pixels that needs to be scrolled to go to the
  /// date provided in the argument
  double _calculateDateOffset(DateTime date) {
    final startDate = new DateTime(
        _datePickerState!.widget.startDate.year,
        _datePickerState!.widget.startDate.month,
        _datePickerState!.widget.startDate.day);

    int offset = date.difference(startDate).inDays;
    return (offset * _datePickerState!.widget.width) + (offset * 6);
  }
}
