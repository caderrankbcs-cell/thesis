import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../widgets/glass_container.dart';

class ResultScreen extends StatelessWidget {
  final PredictionResponse predictionResponse;
  final Map<String, dynamic> inputData;

  const ResultScreen({
    super.key,
    required this.predictionResponse,
    required this.inputData,
  });

  Color _getResultColor(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'high':
      case 'উচ্চ':
        return Colors.greenAccent;
      case 'medium':
      case 'মধ্যম':
        return Colors.amberAccent;
      case 'low':
      case 'নিম্ন':
        return Colors.redAccent;
      default:
        return Colors.cyanAccent;
    }
  }

  String _translatePrediction(String pred) {
    switch (pred.toLowerCase()) {
      case 'high':
        return 'উচ্চ (High - GPA 4.50-5.00)';
      case 'medium':
        return 'মধ্যম (Medium - GPA 3.00-4.49)';
      case 'low':
        return 'নিম্ন (Low - GPA Below 3.00)';
      default:
        return pred;
    }
  }

  IconData _getResultIcon(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'high':
        return Icons.trending_up;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.trending_down;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = _getResultColor(predictionResponse.prediction);
    final bengaliPrediction = _translatePrediction(predictionResponse.prediction);

    return Scaffold(
      appBar: AppBar(
        title: const Text("পূর্বাভাসের ফলাফল (Result)"),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Main Prediction Glass Card
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(24),
              backgroundColor: resultColor.withValues(alpha: 0.1),
              borderColor: resultColor.withValues(alpha: 0.4),
              child: Column(
                children: [
                  Icon(_getResultIcon(predictionResponse.prediction), size: 64, color: resultColor),
                  const SizedBox(height: 14),
                  const Text(
                    "পূর্বাভাসকৃত অর্জনের ক্যাটাগরি",
                    style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bengaliPrediction,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: resultColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "মডেল কনফিডেন্স ক্লাস আইডি: ${predictionResponse.classId}",
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Probabilities Section
            const Text(
              "ক্যাটাগরিভিত্তিক সম্ভাব্যতা (Probabilities)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(18),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              child: Column(
                children: predictionResponse.probabilities.entries.map((entry) {
                  double percentage = entry.value * 100;
                  Color barColor = _getResultColor(entry.key);
                  String label = entry.key;
                  if (label == "High") label = "উচ্চ (High)";
                  if (label == "Medium") label = "মধ্যম (Medium)";
                  if (label == "Low") label = "নিম্ন (Low)";

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            Text("${percentage.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.bold, color: barColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: entry.value,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Explanation Section
            const Text(
              "এই পূর্বাভাসের মূল কারণসমূহ (SHAP Explanation)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(18),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              child: Column(
                children: [
                  ...predictionResponse.explanation.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.analytics, color: Colors.cyanAccent, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.feature, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text("প্রদত্ত মান: ${item.value}", style: TextStyle(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
                            ),
                            Text(
                              "প্রভাব: ${(item.impact * 100).toStringAsFixed(1)}%",
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.cyanAccent),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 28, color: Colors.white24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      "বিশেষ দ্রষ্টব্য: SHAP বিশ্লেষণ মডেলের পূর্বাভাসে বিভিন্ন ফিচারের অবদান নির্দেশ করে, তবে এটি সরাসরি কার্যকারণ (Causality) প্রমাণ করে না।",
                      style: TextStyle(fontSize: 12, color: Colors.amberAccent, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recommendations Section
            const Text(
              "শিক্ষামূলক সুপারিশ ও পরামর্শ (Recommendations)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            ...predictionResponse.recommendations.map((rec) => GlassContainer(
                  borderRadius: 16,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amberAccent, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rec.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(rec.suggestion, style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
