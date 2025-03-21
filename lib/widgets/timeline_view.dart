import 'dart:math' as math;

import 'package:cart_stepper/cart_stepper.dart';
import 'package:flutter/material.dart';
import 'package:lifetalk_editor/providers/node.dart';
import 'package:lifetalk_editor/theme/theme.dart';
import 'package:lifetalk_editor/utils/extension.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  int _scale = 1;
  Node? _activeNode;
  double _timelineSize = 1;
  bool _hasEndOfRangeChanged = false;
  final _scrollController = ScrollController();
  SfRangeValues _values = SfRangeValues(0, 20);

  @override
  void didChangeDependencies() {
    _calculateTimelineSize();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final videoController = YoutubePlayerController.of(context)!;
    final nodeController = NodeController.of(context)!;
    _calculateSelecedRange(nodeController);
    return AnimatedBuilder(
      animation: Listenable.merge([videoController, nodeController]),
      builder: (BuildContext context, _) {
        final selectedNode = nodeController.value;
        if (selectedNode == null) {
          return const SizedBox();
        }

        if (!videoController.value.isReady) {
          return SizedBox();
        }
        if (videoController.value.position.inMilliseconds >= _values.end) {
          videoController.pause();
        }

        final position = videoController.value.position.inMilliseconds;
        final duration = videoController.metadata.duration.inMilliseconds;
        return Stack(
          alignment: Alignment.topRight,
          children: [
            Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.topLeft,
                          colors: <Color>[Colors.white24, Colors.black38],
                        ),
                      ),
                      height: 80,
                      width: _timelineSize,
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 23,
                      child: LinearProgressIndicator(
                        value: duration == 0 ? 0 : position / duration,
                        minHeight: 1,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return SfRangeSliderTheme(
                            data: SfRangeSliderThemeData(
                              thumbRadius: 4,
                              overlappingThumbStrokeColor: Colors.red,
                            ),
                            child: SfRangeSlider(
                              dragMode: SliderDragMode.both,
                              showTicks: true,
                              min: 0,
                              max: duration == 0 ? 60 : duration.toDouble(),
                              values: _values,
                              enableTooltip: true,
                              tooltipTextFormatterCallback: (
                                actualValue,
                                formattedText,
                              ) {
                                return (actualValue as double).toTime();
                              },
                              trackShape: _TrackShape(),
                              onChangeEnd: (value) {
                                _play();
                                if (selectedNode.level != NodeLevel.end) return;
                                var node = nodeController.value!.clone();
                                node.values["range"] =
                                    "${(value.start as double).toTime()}-${(value.end as double).toTime()}";
                                nodeController.value = node;
                              },
                              onChanged: (SfRangeValues newValues) {
                                _hasEndOfRangeChanged =
                                    _values.start == newValues.start;
                                setState(() {
                                  _values = newValues;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CartStepperInt(
              value: _scale,
              didChangeCount:
                  (count) => setState(() {
                    var size = _timelineSize + 0;
                    _calculateTimelineSize();
                    _scrollController.jumpTo(
                      _scrollController.position.pixels *
                          (_timelineSize / size),
                    );
                    _scale = count.min(1);
                  }),
            ),
            Positioned(
              right: 120,
              child: ElevatedButton(
                child: Icon(Icons.replay),
                style: Themes.buttonStyle(),
                onPressed:
                    () => videoController.seekTo(
                      Duration(milliseconds: (_values.start as double).round()),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _calculateSelecedRange(ValueNotifier<Node?> selectedNode) {
    selectedNode.addListener(() {
      if (_activeNode != null && _activeNode!.id == selectedNode.value!.id) {
        return;
      }
      var node = selectedNode.value;
      if (node != null && node.values.containsKey("range")) {
        List<String> ranges = node.values["range"].split("-");
        List<double> values = [];
        for (var range in ranges) {
          values.add(range.parseTime() * 1000);
        }
        _values = SfRangeValues(values[0], values[1]);
        _play();
        _activeNode = node;
      }
    });
  }

  void _calculateTimelineSize() {
    _timelineSize = MediaQuery.of(context).size.width * math.pow(2, _scale - 1);
  }

  void _play() {
    var milis = _hasEndOfRangeChanged ? _values.end - 1000 : _values.start;
    YoutubePlayerController.of(
      context,
    )?.seekTo(Duration(milliseconds: (milis as double).round()));
  }
}

class _TrackShape extends SfTrackShape {
  void paint(
    PaintingContext context,
    Offset offset,
    Offset? thumbCenter,
    Offset? startThumbCenter,
    Offset? endThumbCenter, {
    required RenderBox parentBox,
    required SfSliderThemeData themeData,
    SfRangeValues? currentValues,
    dynamic currentValue,
    required Animation<double> enableAnimation,
    required Paint? inactivePaint,
    required Paint? activePaint,
    required TextDirection textDirection,
  }) {
    Paint paint =
        Paint()
          ..color = themeData.activeTrackColor!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    super.paint(
      context,
      offset,
      thumbCenter,
      startThumbCenter,
      endThumbCenter,
      parentBox: parentBox,
      themeData: themeData,
      enableAnimation: enableAnimation,
      inactivePaint: inactivePaint,
      activePaint: paint,
      textDirection: textDirection,
    );
  }
}
