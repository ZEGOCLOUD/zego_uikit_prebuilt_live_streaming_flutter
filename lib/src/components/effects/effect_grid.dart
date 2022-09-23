// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

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

  int defaultSelectedIndex;
  Map<String, bool> itemsSelected = {};
  List<ZegoEffectGridItem> items = [];

  ZegoEffectGridModel({
    required this.title,
    required this.items,
    this.defaultSelectedIndex = 0,
  }) {
    for (var item in items) {
      itemsSelected[item.id] = false;
    }

    if (items.length > defaultSelectedIndex && defaultSelectedIndex >= 0) {
      itemsSelected[items.elementAt(defaultSelectedIndex).id] = true;
    }
  }

  void clearSelected() {
    itemsSelected.updateAll((key, value) => value = false);
  }
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
                  var bestButtonWidth = _getItemTextSize(item.iconText).width;
                  if (bestButtonWidth > buttonSize.width) {
                    buttonSize = Size(bestButtonWidth, buttonSize.height);
                  }
                  return gridItem(item, buttonSize);
                })
                .map((item) => Row(
                      children: [
                        item,
                        Container(width: widget.itemSpacing ?? 48.r)
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Size _getItemTextSize(String text) {
    final style = TextStyle(
      fontSize: 24.r,
      fontWeight: FontWeight.w500,
    );

    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  Widget gridItem(ZegoEffectGridItem item, Size buttonSize) {
    return ZegoTextIconButton(
      onPressed: () {
        widget.model.clearSelected();
        widget.model.itemsSelected[item.id] = true;
        item.onPressed.call();

        setState(() {}); //  todo
      },
      buttonSize: buttonSize,
      iconSize: widget.iconSize ?? Size(72.r, 72.r),
      iconTextSpacing: 12.r,
      icon: widget.model.itemsSelected[item.id]!
          ? (item.selectIcon ?? item.icon)
          : item.icon,
      iconBorderColor: widget.withBorderColor
          ? (widget.model.itemsSelected[item.id]!
              ? const Color(0xffA653FF)
              : Colors.transparent)
          : Colors.transparent,
      text: item.iconText,
      textStyle: TextStyle(
        color: widget.model.itemsSelected[item.id]!
            ? const Color(0xffA653FF)
            : const Color(0xffCCCCCC),
        fontSize: 24.r,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
