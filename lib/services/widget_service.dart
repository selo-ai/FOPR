import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';

class WidgetService {
  static const String _androidWidgetProvider = 'HomeWidgetProvider';

  static Future<void> updateWidget({
    required double monthlyOvertime,
    required double yearlyOvertime,
    required double monthlyLeave,
    required double yearlyLeave,
  }) async {
    try {
      // Save data
      await HomeWidget.saveWidgetData<String>('monthly_overtime', monthlyOvertime.toStringAsFixed(1));
      await HomeWidget.saveWidgetData<String>('yearly_overtime', yearlyOvertime.toStringAsFixed(1));
      await HomeWidget.saveWidgetData<String>('monthly_leave', monthlyLeave.toStringAsFixed(0));
      await HomeWidget.saveWidgetData<String>('yearly_leave', yearlyLeave.toStringAsFixed(0));
      
      // Trigger update
      await HomeWidget.updateWidget(
        androidName: _androidWidgetProvider,
      );
      debugPrint('Widget updated successfully');
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }
}
