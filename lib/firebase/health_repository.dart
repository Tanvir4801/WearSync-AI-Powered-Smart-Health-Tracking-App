import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/health_data.dart';

class HealthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> saveHealthData({
    required String uid,
    required DateTime date,
    required HealthData data,
  }) async {
    final String dateStr = _dateToString(date);
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('health')
        .doc(dateStr)
        .set(
          <String, dynamic>{
            'steps': data.steps,
            'calories': data.calories,
            'heartRateAvg': data.heartRateAvg,
            'activeMinutes': data.activeMinutes,
            'waterGlasses': data.waterGlasses,
            'createdAt': data.createdAt,
            'updatedAt': data.updatedAt,
          },
        );
  }

  Future<HealthData?> getTodayData({required String uid}) async {
    final DateTime now = DateTime.now();
    final String dateStr = _dateToString(now);

    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('health')
          .doc(dateStr)
          .get();

      if (doc.exists && doc.data() != null) {
        return HealthData.fromJson(doc.data()!);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<HealthData>> getWeekData({required String uid}) async {
    final DateTime now = DateTime.now();
    final DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('health')
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(weekStart.year, weekStart.month, weekStart.day)))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(
                  DateTime(now.year, now.month, now.day, 23, 59, 59)))
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => HealthData.fromJson(doc.data()))
          .toList();
    } catch (_) {
      return <HealthData>[];
    }
  }
}
