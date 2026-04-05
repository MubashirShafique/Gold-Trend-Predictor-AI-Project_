import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gold_trend_predictor/LiveMarketGraph.dart';
import 'dart:math';
import '../models/prediction_response.dart';
import '../services/api_service.dart';
import '../news.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isAnalyzing = false;
  List<FlSpot> chartData = [];
  String _selectedPeriod = "7 Days";

  // Prediction Data
  PredictionResponse? prediction;

  @override
  void initState() {
    super.initState();
    _fetchPrediction(); // API se data fetch
  }

  Future<void> _fetchPrediction() async {
    setState(() => _isAnalyzing = true);
    try {
      final result = await ApiService.getPrediction();
      List<FlSpot> spots = [];
      for (int i = 0; i < result.history.length; i++) {
        spots.add(FlSpot(i.toDouble(), result.history[i]));
      }
      setState(() {
        prediction = result;
        chartData = spots;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _startAnalysis() async {
    await _fetchPrediction();
    if (prediction != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("AI Analysis Complete! Trend Updated."),
          backgroundColor: Color(0xFF1A1A1A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color kGoldColor = Color(0xFFFFD700);
    const Color kDarkBg = Color(0xFF000000);
    const Color kCardBg = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Gold Trend Predictor",
          style: TextStyle(
            color: kGoldColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Welcome ",
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Market Insights",
              style: TextStyle(
                color: kGoldColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Gold is the money of kings. Our AI models analyze complex market patterns for accurate forecasts.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _startAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGoldColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 15,
                  shadowColor: kGoldColor.withOpacity(0.4),
                ),
                child: _isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_graph_sharp, size: 28),
                          SizedBox(width: 15),
                          Text(
                            "PREDICT TOMORROW'S TREND",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),

            // ================= ENHANCED PREDICTION CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(35),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2C2C2C), Color(0xFF050505)],
                ),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: kGoldColor.withOpacity(0.7),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kGoldColor.withOpacity(0.2),
                    blurRadius: 50,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "AI FORECAST (NEXT 24 HOURS)",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Icon(
                    prediction != null
                        ? (prediction!.prediction == 1
                              ? Icons.arrow_circle_up_rounded
                              : Icons.arrow_circle_down_rounded)
                        : Icons.auto_graph,
                    color: prediction != null
                        ? (prediction!.prediction == 1
                              ? Colors.greenAccent
                              : Colors.redAccent)
                        : Colors.white,
                    size: 100,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    prediction != null
                        ? (prediction!.prediction == 1
                              ? "BULLISH (UP)"
                              : "BEARISH")
                        : "LOADING...",
                    style: TextStyle(
                      color: prediction != null
                          ? (prediction!.prediction == 1
                                ? Colors.greenAccent
                                : Colors.redAccent)
                          : Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: prediction != null
                            ? (prediction!.prediction == 1
                                  ? Colors.greenAccent.withOpacity(0.4)
                                  : Colors.redAccent.withOpacity(0.4))
                            : Colors.white24,
                      ),
                    ),
                    child: Text(
                      prediction != null
                          ? "Model Confidence: ${(prediction!.confidence * 100).toStringAsFixed(2)}%"
                          : "Fetching data...",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 70),

            // ================= LIVE PRICE CARDS =================
            Row(
              children: [
                _buildStatCard(
                  "Current Price",
                  prediction != null
                      ? "\$${prediction!.history.last.toStringAsFixed(2)}"
                      : "\$--",
                  Colors.white,
                  Icons.bolt,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  "24h Change",
                  prediction != null
                      ? "\$${(prediction!.history.last - prediction!.history[prediction!.history.length - 2]).toStringAsFixed(2)}"
                      : "\$--",
                  prediction != null &&
                          (prediction!.history.last -
                                  prediction!.history[prediction!
                                          .history
                                          .length -
                                      2]) >=
                              0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ================= GRAPH SECTION =================
            const Text(
              "Live Market Trend",
              style: TextStyle(
                color: kGoldColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            LiveMarketGraph(
              chartData:
                  chartData, // PredictionResponse se nikal ke list<FlSpot>
              labels:
                  prediction?.historyDates
                      .takeLast(chartData.length)
                      .toList() ??
                  [],
              selectedPeriod: _selectedPeriod,
            ),

            // Time Selector Chips
            const SizedBox(height: 40),

            Row(
              children: [
                _buildInsightCard(
                  "Highest (Week)",
                  prediction != null
                      ? "\$${prediction!.history.reduce(max).toStringAsFixed(2)}"
                      : "\$--",
                  Colors.orangeAccent,
                  Icons.arrow_upward,
                ),
                const SizedBox(width: 12),
                _buildInsightCard(
                  "Lowest (Week)",
                  prediction != null
                      ? "\$${prediction!.history.reduce(min).toStringAsFixed(2)}"
                      : "\$--",
                  Colors.blueAccent,
                  Icons.arrow_downward,
                ),
              ],
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFD4AF37),
                        Color(0xFFFFD700),
                        Color(0xFFCFB53B),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      "BREAKING NEWS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFFD700,
                            ).withOpacity(0.4), // Golden Glow
                            spreadRadius: 2,
                            blurRadius: 15,
                            offset: const Offset(0, 4), // Glow ki direction
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GoldNewsRSS(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700), // Pure Gold
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              15,
                            ), // Smooth corners
                          ),
                          elevation:
                              0, // Elevation 0 rakhi hai kyunki Container ka shadow use ho raha hai
                        ),
                        child: const Text(
                          "Open Gold News",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing:
                                1.2, // Text thora khula aur premium lagega
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color valColor,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white38, size: 16),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    String label,
    String price,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF09090C),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
