import 'package:app/core/text_rect_block.dart';
import 'package:app/utils/text.dart';

class MenuRectBlock {
  String text;
  TextRectBlock textRectBlock;

  MenuRectBlock({
    required this.text,
    required this.textRectBlock,
  });

  /// Check combinable state based on box coordinates
  ///
  /// `toleranceX` - avg height of blocks
  ///
  /// `toleranceY` - avg height / 2 of blocks
  static bool getCombinableState(
    MenuRectBlock target,
    MenuRectBlock combineTarget, {
    required int toleranceX,
    required int toleranceY,
  }) {
    final isSelfConflict = target.text.contains(combineTarget.text);
    if (isSelfConflict) return false;

    if (isPriceText(target.text) || isPriceText(combineTarget.text)) {
      return false;
    }

    final targetA = target.textRectBlock;
    final targetB = combineTarget.textRectBlock;
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
  factory MenuRectBlock.combine(
    MenuRectBlock target,
    MenuRectBlock combineTarget,
  ) {
    final targetA = target.textRectBlock;
    final targetB = combineTarget.textRectBlock;
    final isTargetALeft = targetA.center.x <= targetB.center.x;

    return MenuRectBlock(
      text: isTargetALeft
          ? "${target.text} ${combineTarget.text}"
          : "${combineTarget.text} ${target.text}",
      textRectBlock: TextRectBlock(
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
    return "\n{ \n   text: $text, \n   textRectBlock: $textRectBlock }";
  }
}
