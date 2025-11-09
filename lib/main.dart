import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ShakeQuoteApp());
}

class ShakeQuoteApp extends StatefulWidget {
  const ShakeQuoteApp({Key? key}) : super(key: key);

  @override
  State<ShakeQuoteApp> createState() => _ShakeQuoteAppState();
}

class _ShakeQuoteAppState extends State<ShakeQuoteApp>
    with SingleTickerProviderStateMixin {
  static const EventChannel _shakeChannel = EventChannel(
    'com.example.shakequote/shake',
  );
  static const MethodChannel _methodChannel = MethodChannel(
    'com.example.shakequote/control',
  );

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  StreamSubscription? _shakeSubscription;

  String _currentQuote = "";
  final Random _random = Random();

  final List<String> _quotes = [
    "Believe you can and you're halfway there. – Theodore Roosevelt",
    "The only way to do great work is to love what you do. – Steve Jobs",
    "Success is not final, failure is not fatal. – Winston Churchill",
    "Don't watch the clock; do what it does. Keep going. – Sam Levenson",
    "The future belongs to those who believe in their dreams. – Eleanor Roosevelt",
    "You are never too old to set another goal. – C.S. Lewis",
    "It always seems impossible until it's done. – Nelson Mandela",
    "Start where you are. Use what you have. Do what you can. – Arthur Ashe",
    "The secret of getting ahead is getting started. – Mark Twain",
    "Don't limit yourself. Many people limit themselves to what they think they can do.",
    "Study hard what interests you the most in the most undisciplined way. – Richard Feynman",
    "Education is the passport to the future. – Malcolm X",
    "The expert in anything was once a beginner. – Helen Hayes",
    "Learning never exhausts the mind. – Leonardo da Vinci",
    "Stay focused, go after your dreams, and keep moving toward your goals. – LL Cool J",
  ];

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initializeShakeChannel();
    _displayRandomQuote();
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _initializeShakeChannel() async {
    try {
      await _methodChannel.invokeMethod('startShakeDetection');
      _shakeSubscription = _shakeChannel.receiveBroadcastStream().listen((
        event,
      ) {
        if (event == "onShakeDetected") {
          _onShakeDetected();
        }
      });
    } on PlatformException catch (e) {
      debugPrint("Error initializing shake: $e");
    }
  }

  void _displayRandomQuote() {
    setState(() {
      _currentQuote = _quotes[_random.nextInt(_quotes.length)];
    });
  }

  void _onShakeDetected() {
    HapticFeedback.mediumImpact();
    _controller.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200), () {
      _displayRandomQuote();
    });
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shake for Motivation',
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(100, 149, 237, 0.4),
                Color.fromRGBO(138, 43, 226, 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          const Icon(
                            Icons.wifi_tethering,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Shake for Motivation",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.format_quote_rounded,
                                  color: Colors.blue,
                                  size: 48,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _currentQuote,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              "🤳 Shake your phone to get a new quote",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
