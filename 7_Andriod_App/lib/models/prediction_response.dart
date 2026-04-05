class PredictionResponse {
  final int prediction;
  final double confidence;
  final List<double> history;
  final List<String> historyDates; // naya

  PredictionResponse({
    required this.prediction,
    required this.confidence,
    required this.history,
    required this.historyDates,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    List<double> historyList = [];
    List<String> historyDates = [];

    if (json['history_data'] != null) {
      for (var item in json['history_data']) {
        historyList.add((item['final_price'] as num).toDouble());
        historyDates.add(item['Date'] as String);
      }
    }

    return PredictionResponse(
      prediction: json['prediction'],
      confidence: (json['confidence_score'] as num).toDouble(),
      history: historyList,
      historyDates: historyDates,
    );
  }
}