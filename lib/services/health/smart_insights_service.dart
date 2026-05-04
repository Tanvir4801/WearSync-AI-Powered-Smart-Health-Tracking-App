import 'models/daily_steps.dart';
import 'models/smart_insight.dart';
import '../../firebase/models/health_data.dart';

class SmartInsightsService {
  SmartInsight analyzeActivity(List<DailySteps> weekData) {
    if (weekData.isEmpty) {
      return const SmartInsight(
        headline: 'Start your journey',
        detail: 'Begin tracking your daily steps to get personalized insights.',
        suggestion: 'Take a walk today to kick off your fitness journey!',
        type: SmartInsightType.tip,
      );
    }

    final int todaySteps = weekData.last.steps;
    final double avgSteps = weekData.fold<int>(0, (sum, day) => sum + day.steps) / weekData.length;
    final int maxSteps = weekData.map((day) => day.steps).reduce((a, b) => a > b ? a : b);

    // Check for low activity day
    if (todaySteps < avgSteps * 0.5 && todaySteps > 0) {
      return SmartInsight(
        headline: 'Low activity day',
        detail: 'Today\'s steps (${todaySteps ~/ 1000}k) are 50% below your average.',
        suggestion: 'Try to add 20 minutes of walking to boost your daily count.',
        type: SmartInsightType.warning,
      );
    }

    // Check for great streak
    int consecutiveAboveGoal = 0;
    for (int i = weekData.length - 1; i >= 0; i--) {
      if (weekData[i].steps > 10000) {
        consecutiveAboveGoal++;
      } else {
        break;
      }
    }

    if (consecutiveAboveGoal >= 3) {
      return SmartInsight(
        headline: 'Great streak!',
        detail: '$consecutiveAboveGoal days in a row above 10,000 steps!',
        suggestion: 'Keep it up! You\'re building amazing momentum.',
        type: SmartInsightType.positive,
      );
    }

    // Check if peak was days ago
    int daysSinceMax = 0;
    for (int i = weekData.length - 1; i >= 0; i--) {
      if (weekData[i].steps == maxSteps && i < weekData.length - 1) {
        daysSinceMax = weekData.length - 1 - i;
        break;
      }
    }

    if (daysSinceMax >= 3 && maxSteps > avgSteps * 1.5) {
      return SmartInsight(
        headline: 'You peaked earlier this week',
        detail: 'Your best day ($maxSteps steps) was $daysSinceMax days ago.',
        suggestion: 'Aim to match or exceed that peak day soon!',
        type: SmartInsightType.tip,
      );
    }

    // Default positive insight
    if (todaySteps > avgSteps) {
      return SmartInsight(
        headline: 'On pace today',
        detail: 'You\'re ${((todaySteps - avgSteps) / avgSteps * 100).toStringAsFixed(0)}% above your average.',
        suggestion: 'Great work! Keep moving to crush your goals.',
        type: SmartInsightType.positive,
      );
    }

    return SmartInsight(
      headline: 'Keep moving',
      detail: 'You\'re at ${todaySteps ~/ 1000}k steps today.',
      suggestion: 'Try to add more steps throughout the day.',
      type: SmartInsightType.tip,
    );
  }

  String generateDailySummary(HealthData today) {
    final int activeMin = today.activeMinutes;
    final int steps = today.steps;
    final int calories = today.calories;

    if (activeMin == 0) {
      return 'Great day ahead! You took $steps steps and burned $calories calories. Stay active!';
    }

    return 'Daily Summary: $steps steps, $activeMin minutes active, $calories calories burned. Well done!';
  }
}
