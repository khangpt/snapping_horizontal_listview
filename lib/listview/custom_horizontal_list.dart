import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

enum CustomHorizontalListType { normal, carousel, snapping }

// ignore: must_be_immutable
class CustomHorizontalList<T> extends StatelessWidget {
  CustomHorizontalList(
    this.items, {
    required this.itemWidth,
    required this.itemHeight,
    required this.itemBuilder,
    this.listType = CustomHorizontalListType.normal,
    this.isAutoPlay = false,
    this.infiniteScroll = false,
    this.initialPageIndex = 0,
    this.backgroundColor,
    this.paddingBetweenItem,
    this.contentPadding,
    double? verticalPadding,
    Key? key,
  })  : _verticalPadding = verticalPadding ?? 0,
        super(key: key);

  final CustomHorizontalListType listType;
  final List<T> items;
  final double itemWidth;
  final double itemHeight;
  final Widget Function(T item, int index) itemBuilder;
  final Color? backgroundColor;
  final double? paddingBetweenItem;
  final double? contentPadding;

  /// carousel list type only
  final bool isAutoPlay;

  /// carousel list type only
  final bool infiniteScroll;

  /// carousel list type only
  final int initialPageIndex;

  final double _verticalPadding;

  double? _viewportRatio;

  @override
  Widget build(BuildContext context) {
    _viewportRatio ??= itemWidth / MediaQuery.of(context).size.width;

    switch (listType) {
      case CustomHorizontalListType.carousel:
        return Container(
          color: backgroundColor,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: itemHeight + _verticalPadding,
              viewportFraction: _viewportRatio!,
              // aspectRatio: itemWidth / itemHeight,
              scrollPhysics: null,
              autoPlay: isAutoPlay,
              autoPlayInterval: const Duration(seconds: 5),
              initialPage: initialPageIndex,
              scrollDirection: Axis.horizontal,
              // enlargeStrategy: CenterPageEnlargeStrategy.height,
              // enlargeCenterPage: false,
              // disableCenter: false,
              // pageSnapping: true,
              enableInfiniteScroll: infiniteScroll,
            ),
            itemCount: items.length,
            itemBuilder: (_, index, __) {
              final itemAtIndex = items[index];

              return Center(child: itemBuilder(itemAtIndex, index));
            },
          ),
        );

      case CustomHorizontalListType.snapping:
        return Container(
          color: backgroundColor,
          height: itemHeight + _verticalPadding,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: _SnapScrollPhysics(itemDimension: itemWidth + (paddingBetweenItem ?? 0)),
            padding: EdgeInsets.symmetric(horizontal: contentPadding ?? 0),
            separatorBuilder: (_, index) => SizedBox(width: paddingBetweenItem),
            itemCount: items.length,
            itemBuilder: (_, index) {
              final itemAtIndex = items[index];

              return itemBuilder(itemAtIndex, index);
            },
          ),
        );

      case CustomHorizontalListType.normal:
      default:
        return Container(
          color: backgroundColor,
          height: itemHeight + _verticalPadding,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: null,
            padding: EdgeInsets.symmetric(horizontal: contentPadding ?? 0),
            separatorBuilder: (_, index) => SizedBox(width: paddingBetweenItem),
            itemCount: items.length,
            itemBuilder: (_, index) {
              final itemAtIndex = items[index];

              return itemBuilder(itemAtIndex, index);
            },
          ),
        );
    }
  }
}

class _SnapScrollPhysics extends ScrollPhysics {
  const _SnapScrollPhysics({
    required this.itemDimension,
    this.speedUp = 3000.0,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  final double itemDimension;
  final double speedUp;

  @override
  bool get allowImplicitScrolling => false;

  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnapScrollPhysics(itemDimension: itemDimension, parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    /// If we're out of range and not headed back in range, defer to the parent
    /// ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent) ||
        position.outOfRange ||
        velocity < -speedUp ||
        velocity > speedUp) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = this.tolerance;

    final portion = (position.extentInside - itemDimension) / 2;
    final double target = _getTargetPixels(position, tolerance, velocity, portion);

    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }

    return null;
  }

  double _getPage(ScrollMetrics position, double portion) {
    return (position.pixels + portion) / itemDimension;
  }

  double _getPixels(double page, double portion) {
    return (page * itemDimension) - portion;
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
    double portion,
  ) {
    double page = _getPage(position, portion);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }

    return _getPixels(page.roundToDouble(), portion);
  }
}
