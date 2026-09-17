import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("গবেষণা ও পদ্ধতি (About Research)"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "গবেষণার উদ্দেশ্য (Research Objective)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "\"A Multi-Level Explainable Machine Learning Approach to Predict SSC Performance Using Student and School-Level Factors in Bangladesh\" শীর্ষক গবেষণার অংশ হিসেবে এই অ্যাপটি তৈরি। এর মূল লক্ষ্য হলো শিক্ষার্থীদের শিক্ষাগত, পারিবারিক, আচরণগত, মনস্তাত্ত্বিক এবং বিদ্যালয়-সম্পর্কিত বিভিন্ন উপাত্ত বিশ্লেষণ করে এসএসসি পরীক্ষার ফলাফলের পূর্বাভাস দেওয়া এবং কার্যকর শিক্ষামূলক সুপারিশ প্রদান করা।",
                    style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ডেটাসেট ও পদ্ধতি (Dataset & Methodology)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• নমুনা আকার: ১২৩টি প্রতিষ্ঠানের মোট ৫০৮ জন এসএসসি শিক্ষার্থী।\n"
                    "• ফিচ ইঞ্জিনিয়ারিং: সাইকমেট্রিক ভ্যালিডেশন (ক্রনবাখ আলফা > ০.৭০) সহ ৩২টি নির্ধারিত প্রিডিক্টর।\n"
                    "• লক্ষ্যমাত্রা (Target): অর্জন অর্ডিনাল (Achievement Ordinal - ৩টি ক্যাটাগরি: নিম্ন, মধ্যম, উচ্চ)।\n"
                    "• ডাটা লিক্যাজ প্রতিরোধ: পূর্ববর্তী জিপিএ এবং সরাসরি পূর্ববর্তী ফলাফল বাদ দেওয়া হয়েছে।",
                    style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "মেশিন লার্নিং ও এক্সপ্লেইনেবল এআই (XAI)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• নির্বাচিত সেরা মডেল: XGBoost + LightGBM + Extra Trees + SVM Stacking Ensemble\n"
                    "• কার্যকারিতা:\n"
                    "  - সঠিকতা (Accuracy): ৯২.৫১%\n"
                    "  - ম্যাক্রো এফ১-স্কোর (Macro F1): ০.৮১৩\n"
                    "  - ব্যালেন্সড সঠিকতা (Balanced Accuracy): ০.৭৬৮\n"
                    "• ব্যাখ্যাযোগ্যতা: SHAP ও LIME বিশ্লেষণের মাধ্যমে প্রতিটি শিক্ষার্থীর ফলাফলের পেছনের মূল কারণ ও প্রভাব দৃশ্যমান করা হয়।",
                    style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
