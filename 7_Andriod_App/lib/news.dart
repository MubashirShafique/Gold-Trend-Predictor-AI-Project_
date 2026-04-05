import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsArticle {
  final String title;
  final String link;
  final String pubDate;

  NewsArticle({
    required this.title,
    required this.link,
    required this.pubDate,
  });
}

class GoldNewsRSS extends StatefulWidget {
  const GoldNewsRSS({super.key});

  @override
  State<GoldNewsRSS> createState() => _GoldNewsRSSState();
}

class _GoldNewsRSSState extends State<GoldNewsRSS> {
  List<NewsArticle> news = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRSS();
  }

  Future<void> fetchRSS() async {
    final url = Uri.parse(
        "https://news.google.com/rss/search?q=gold%20OR%20XAU%20OR%20%22gold%20price%22%20OR%20bullion&hl=en-US&gl=US&ceid=US:en");

    final response = await http.get(url);
    final document = XmlDocument.parse(response.body);
    final items = document.findAllElements('item');

    setState(() {
      news = items.map((item) {
        return NewsArticle(
          title: item.findElements('title').single.text,
          link: item.findElements('link').single.text,
          pubDate: item.findElements('pubDate').single.text,
        );
      }).toList();

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "GOLD NEWS",
          style: TextStyle(
            color: goldColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: goldColor))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: news.length,
        itemBuilder: (context, index) {
          final item = news[index];

          return NeonNewsTile(
            title: item.title,
            date: item.pubDate,
            link: item.link,
          );
        },
      ),
    );
  }
}

class NeonNewsTile extends StatefulWidget {
  final String title;
  final String date;
  final String link;

  const NeonNewsTile({
    super.key,
    required this.title,
    required this.date,
    required this.link,
  });

  @override
  State<NeonNewsTile> createState() => _NeonNewsTileState();
}

class _NeonNewsTileState extends State<NeonNewsTile> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    const neonColor = Color(0xFFFFFF00);
    const goldColor = Color(0xFFD4AF37);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isPressed
                ? neonColor.withOpacity(0.6)
                : Colors.black.withOpacity(0.3),
            blurRadius: isPressed ? 25 : 8,
            spreadRadius: isPressed ? 3 : 1,
          )
        ],
        border: Border.all(
          color: isPressed ? neonColor : Colors.white10,
          width: isPressed ? 2.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: () async {
          await launchUrl(Uri.parse(widget.link));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: isPressed ? neonColor : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.date,
                style: TextStyle(
                  color: goldColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}