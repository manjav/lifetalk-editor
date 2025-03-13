import 'package:cart_stepper/cart_stepper.dart';
import 'package:flutter/material.dart';
import 'package:lifetalk_editor/utils/extension.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:math' as math;

class Trimmer extends StatefulWidget {
  final YoutubePlayerController controller;

  const Trimmer(this.controller, {super.key});

  @override
  State<Trimmer> createState() => _TrimmerState();
}

class _TrimmerState extends State<Trimmer> {

  int _scale = 1;
  double _timelineSize = 1;
  SfRangeValues _values = SfRangeValues(0, 20);

  @override
  void initState() {
    _calculateTimelineSize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        if (!value.isReady) {
          return SizedBox();
        }
        if (value.position.inMilliseconds >= _values.end) {
          widget.controller.pause();
        }
        final position = value.position.inMilliseconds;
        final duration = widget.controller.metadata.duration.inMilliseconds;
        return Stack(
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
                        print(value);
                        widget.controller.seekTo(
                          Duration(
                                    milliseconds:
                                        (_values.start as double).round(),
                          ),
                        );
                      },
                      onChanged: (SfRangeValues newValues) {
                        setState(() => _values = newValues);
                      },
                    ),
                  );
                },
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
            ),
          ],
        );
      },
    );
  }

  void _calculateTimelineSize() {
    _timelineSize = MediaQuery.of(context).size.width * math.pow(2, _scale - 1);
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
