import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ConnectView());
  }
}

class ConnectView extends StatelessWidget {
  const ConnectView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.access_time_filled_outlined,
              Icons.yard,
              Icons.work_outlined,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      );
}

class Dock<P extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<P> items;

  final Widget Function(P) builder;

  @override
  State<Dock<P>> createState() => _DockState<P>();
}

class _DockState<P extends Object> extends State<Dock<P>> {
  late List<P> _items = widget.items.toList();

  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items
            .asMap()
            .entries
            .map(
              (entry) => MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _hoveredIndex = entry.key;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _hoveredIndex = null;
                  });
                },
                child: LongPressDraggable<P>(
                  data: entry.value,
                  onDragStarted: () {
                    setState(() {
                      _hoveredIndex = null;
                    });
                  },
                  onDragCompleted: () {
                    setState(() {});
                  },
                  onDraggableCanceled: (_, __) {
                    setState(() {});
                  },
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.7,
                      child: widget.builder(entry.value),
                    ),
                  ),
                  childWhenDragging: SizedBox.shrink(),
                  child: DragTarget<P>(
                    onAccept: (receivedItem) {
                      setState(() {
                        final draggedIndex = _items.indexOf(receivedItem);
                        final targetIndex = entry.key;

                        _items
                          ..removeAt(draggedIndex)
                          ..insert(targetIndex, receivedItem);
                      });
                    },
                    
                    onWillAccept: (receivedItem) => receivedItem != entry.value,
                    builder: (context, acceptedItems, rejectedItems) =>
                        TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      tween: Tween<double>(
                        begin: 0.0,
                        end: _hoveredIndex == entry.key
                            ? -10.0
                            : (_hoveredIndex == entry.key - 1 ||
                                    _hoveredIndex == entry.key + 1)
                                ? -5.0
                                : 0.0,
                      ),
                      builder: (context, translateY, child) {
                        return Transform.translate(
                          offset: Offset(0, translateY),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            tween: Tween<double>(
                              begin: 1.0,
                              end: _hoveredIndex == entry.key
                                  ? 1.2
                                  : (_hoveredIndex == entry.key - 1 ||
                                          _hoveredIndex == entry.key + 1)
                                      ? 1.1
                                      : 1.0,
                            ),
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: widget.builder(entry.value),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
