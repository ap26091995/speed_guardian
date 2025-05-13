import 'package:flutter/material.dart';

class ContinuousCarousel extends StatefulWidget {
  final List<Widget> items;
  final Duration scrollDuration;
  final double itemWidth;
  final double spacing;

  const ContinuousCarousel({
    super.key,
    required this.items,
    this.scrollDuration = const Duration(seconds: 3),
    this.itemWidth = 200.0,
    this.spacing = 10.0,
  });

  @override
  State<ContinuousCarousel> createState() => _ContinuousCarouselState();
}

class _ContinuousCarouselState extends State<ContinuousCarousel>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _animationController = AnimationController(
      vsync: this,
      duration: widget.scrollDuration,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  @override
  void didUpdateWidget(covariant ContinuousCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollDuration != widget.scrollDuration) {
      _animationController.duration = widget.scrollDuration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final currentOffset = _scrollController.offset;

        if (currentOffset >= maxScrollExtent) {
          _scrollController.jumpTo(0.0);
        }

        _animationController.animateTo(
          1.0,
          curve: Curves.linear,
          duration: widget.scrollDuration,
        );

        await _animationController.isCompleted;
        _animationController.reset();

        // Slightly advance the scroll position for the next animation
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.offset + 1);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0, // Adjust as needed
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        reverse: true, // To make it scroll right to left initially
        itemCount: widget.items.length * 2, // Duplicate for seamless loop
        itemBuilder: (context, index) {
          final itemIndex = index % widget.items.length;
          return SizedBox(
            width: widget.itemWidth,
            child: Padding(
              padding: EdgeInsets.only(left: itemIndex == 0 ? 0 : widget.spacing),
              child: widget.items[itemIndex],
            ),
          );
        },
      ),
    );
  }
}

// Example usage:
class CarouselBanners extends StatelessWidget {
  const CarouselBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Continuous Carousel Example'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ContinuousCarousel(
            items:  [
            Image.asset(
              'assets/images/logo.png',
              // fit: BoxFit.fill,
              // height: MediaQuery.of(context).size.height,
            ),
              Text('Important Update!', style: TextStyle(fontSize: 16)),
              Text('New Product Launched', style: TextStyle(fontSize: 16)),
              Text('Special Announcement', style: TextStyle(fontSize: 16)),
            ],
            scrollDuration: const Duration(seconds: 4),
            itemWidth: 180.0,
            spacing: 20.0,
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: CarouselBanners()));
}