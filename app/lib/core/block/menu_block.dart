import 'package:app/core/block/block.dart';
import 'package:app/utils/text.dart';

class MenuBlock {
  String text;
  Block block;

  MenuBlock({
    required this.text,
    required this.block,
  });

  /// Check combinable state based on box coordinates
  ///
  /// `toleranceX` - avg height of blocks
  ///
  /// `toleranceY` - avg height / `2` of blocks
  static bool getCombinableState(
    MenuBlock target,
    MenuBlock combineTarget, {
    required int toleranceX,
    required int toleranceY,
  }) {
    final isSelfConflict = target.text.contains(combineTarget.text);
    if (isSelfConflict) return false;

    if (isPriceText(target.text) || isPriceText(combineTarget.text)) {
      return false;
    }

    final targetA = target.block;
    final targetB = combineTarget.block;
    final isTargetLocationIsLeft = targetA.center.x <= targetB.center.x;

    final distanceX = isTargetLocationIsLeft
        ? (targetB.tl.x - targetA.tr.x).abs()
        : (targetA.tl.x - targetB.tr.x).abs();
    final distanceY = (targetA.center.y - targetB.center.y).abs();

    final isCombinable = distanceX <= toleranceX && distanceY <= toleranceY;
    return isCombinable;
  }

  /// Combine two block into one block
  ///
  /// use it with `MenuRectBlock.getCombinableState()`
  ///
  /// ```dart
  /// final block1 = "...";
  /// final block2 = "...";
  /// ///check condition
  /// if (MenuRectBlock.getCombinableState(
  ///   block1,
  ///   block2,
  /// )) {
  ///   final combinedBlock = MenuRectBlock.combine(
  ///     block1,
  ///     block2,
  ///   );
  ///}
  /// ```
  factory MenuBlock.combine(
    MenuBlock target,
    MenuBlock combineTarget,
  ) {
    final targetA = target.block;
    final targetB = combineTarget.block;
    final isTargetALeft = targetA.center.x <= targetB.center.x;

    return MenuBlock(
      text: isTargetALeft
          ? "${target.text} ${combineTarget.text}"
          : "${combineTarget.text} ${target.text}",
      block: Block(
        initialPosition: isTargetALeft
            ? RectPosition(
                tl: targetA.tl,
                bl: targetA.bl,
                tr: targetB.tr,
                br: targetB.br,
              )
            : RectPosition(
                tl: targetB.tl,
                bl: targetB.bl,
                tr: targetA.tr,
                br: targetA.br,
              ),
      ),
    );
  }

  @override
  String toString() {
    return "\n{ \n   text: $text, \n   textRectBlock: $block }";
  }
}
