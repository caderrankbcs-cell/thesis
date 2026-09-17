import 'package:flutter/material.dart';
import 'prediction_form_screen.dart';
import 'about_screen.dart';
import '../services/api_service.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() => isChecking = true);
    bool healthy = await ApiService.checkHealth();
    setState(() {
      isConnected = healthy;
      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("এসএসসি শিক্ষাগত সাফল্য পূর্বাভাস"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                // Header Glass Banner
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(24),
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.school, color: Colors.amberAccent, size: 40),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "শিক্ষার্থী সাফল্য পূর্বাভাস সিস্টেম",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "ছাত্র-ছাত্রীদের পারিবারিক, সামাজিক, প্রাতিষ্ঠানিক ও মনস্তাত্ত্বিক উপাত্ত বিশ্লেষণের মাধ্যমে এসএসসি পরীক্ষার ফলাফল পূর্বাভাসের একটি উন্নত কৃত্রিম বুদ্ধিমত্তাভিত্তিক সিস্টেম।",
                        style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isChecking ? Icons.sync : (isConnected ? Icons.check_circle : Icons.error),
                                color: isChecking ? Colors.orange : (isConnected ? Colors.greenAccent : Colors.redAccent),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isChecking ? "সার্ভার যাচাই হচ্ছে..." : (isConnected ? "ব্যাকএন্ড অনলাইন" : "ব্যাকএন্ড অফলাইন"),
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _testConnection,
                            icon: const Icon(Icons.refresh, size: 16, color: Colors.amberAccent),
                            label: const Text("পুনরায় চেষ্টা", style: TextStyle(color: Colors.amberAccent)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Model Statistics Section
                const Text(
                  "গবেষণা মডেলের কার্যকারিতা",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildGlassStatCard("মডেল সঠিকতা (Accuracy)", "৯২.৫১%", Icons.insights, Colors.cyanAccent),
                    _buildGlassStatCard("ব্যালেন্সড সঠিকতা", "০.৭৬৮", Icons.balance, Colors.tealAccent),
                    _buildGlassStatCard("ম্যাক্রো এফ১-স্কোর", "০.৮১৩", Icons.analytics, Colors.amberAccent),
                    _buildGlassStatCard("সেরা মডেল", "Stacking Ensemble", Icons.star, Colors.purpleAccent),
                  ],
                ),
                const SizedBox(height: 34),

                // Action Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PredictionFormScreen()),
                      );
                    },
                    icon: const Icon(Icons.psychology, size: 26, color: Colors.white),
                    label: const Text(
                      "শিক্ষার্থীর মূল্যায়ন শুরু করুন",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStatCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      borderRadius: 14,
      padding: const EdgeInsets.all(12),
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
