// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';

class ZegoEffectGridItem<T> {
  String id;
  T effectType;

  ButtonIcon icon;
  ButtonIcon? selectIcon;
  String iconText;
  VoidCallback onPressed;

  ZegoEffectGridItem({
    required this.id,
    required this.effectType,
    required this.icon,
    required this.iconText,
    required this.onPressed,
    this.selectIcon,
  });
}

class ZegoEffectGridModel {
  String title;

  ValueNotifier<String> selectedID;
  List<ZegoEffectGridItem> items = [];

  ZegoEffectGridModel({
    required this.title,
    required this.items,
    required this.selectedID,
  });
}

class ZegoEffectGrid extends StatefulWidget {
  const ZegoEffectGrid({
    Key? key,
    required this.model,
    required this.isSpaceEvenly,
    this.buttonSize,
    this.iconSize,
    this.withBorderColor = false,
    this.itemSpacing,
  }) : super(key: key);

  final ZegoEffectGridModel model;
  final bool withBorderColor;
  final Size? buttonSize;
  final Size? iconSize;
  final bool isSpaceEvenly;
  final double? itemSpacing;

  @override
  State<ZegoEffectGrid> createState() => _ZegoEffectGridState();
}

class _ZegoEffectGridState extends State<ZegoEffectGrid> {
  TextStyle get gridItemTextStyle => TextStyle(
        fontSize: 24.r,
        fontWeight: FontWeight.w500,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header(),
          line(),
          SizedBox(
            height: 133.r,
            child: grid(),
          )
        ],
      ),
    );
  }

  Widget header() {
    return widget.model.title.isEmpty
        ? Container()
        : Text(
            widget.model.title,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 26.r,
              color: Colors.white,
            ),
          );
  }

  Widget line() {
    return widget.model.title.isEmpty ? Container() : SizedBox(height: 30.r);
  }

  Widget grid() {
    if (widget.isSpaceEvenly) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.model.items.map((item) {
          return gridItem(item, widget.buttonSize ?? Size(88.r, 133.r));
        }).toList(),
      );
    }

    return CustomScrollView(
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: widget.model.items
                .map((item) {
                  var buttonSize = widget.buttonSize ?? Size(88.r, 133.r);
                  var bestButtonWidth =
                      getTextSize(item.iconText, gridItemTextStyle).width;
                  buttonSize = Size(
                    bestButtonWidth + 20.r,
                    buttonSize.height,
                  );
                  return gridItem(item, buttonSize);
                })
                .map((item) => Row(
                      children: [
                        item,
                        Container(width: widget.itemSpacing ?? 40.r)
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget gridItem(ZegoEffectGridItem item, Size buttonSize) {
    return ZegoTextIconButton(
      onPressed: () {
        widget.model.selectedID.value = item.id;
        item.onPressed.call();

        setState(() {}); //  todo
      },
      buttonSize: buttonSize,
      iconSize: widget.iconSize ?? Size(72.r, 72.r),
      iconTextSpacing: 12.r,
      icon: item.id == widget.model.selectedID.value
          ? (item.selectIcon ?? item.icon)
          : item.icon,
      iconBorderColor: widget.withBorderColor
          ? (item.id == widget.model.selectedID.value
              ? const Color(0xffA653FF)
              : Colors.transparent)
          : Colors.transparent,
      text: item.iconText,
      textStyle: TextStyle(
        color: item.id == widget.model.selectedID.value
            ? const Color(0xffA653FF)
            : const Color(0xffCCCCCC),
        fontSize: 24.r,
        fontWeight: FontWeight.w500,
      ),
      softWrap: false,
    );
  }
}
