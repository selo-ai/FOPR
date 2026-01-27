package com.nlo.fopr

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.nlo.fopr.R

class HomeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Get data from SharedPreferences
                val monthlyOvertime = widgetData.getString("monthly_overtime", "0.0")
                val yearlyOvertime = widgetData.getString("yearly_overtime", "0.0")
                val monthlyLeave = widgetData.getString("monthly_leave", "0")
                val yearlyLeave = widgetData.getString("yearly_leave", "0")

                // Update text views
                setTextViewText(R.id.tv_monthly_overtime, monthlyOvertime)
                setTextViewText(R.id.tv_yearly_overtime, yearlyOvertime)
                setTextViewText(R.id.tv_monthly_leave, monthlyLeave)
                setTextViewText(R.id.tv_remaining_leave, yearlyLeave)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
