import 'package:app/core/text_rect_block.dart';

class MenuRectBlock {
  String text;
  TextRectBlock textRectBlock;

  MenuRectBlock({
    required this.text,
    required this.textRectBlock,
  });

  static bool getCombinableState(
    MenuRectBlock target,
    MenuRectBlock combineTarget,
  ) {
    final isSelfConflict = target.text.contains(combineTarget.text);
    if (isSelfConflict) return false;

    final targetA = target.textRectBlock;
    final targetB = combineTarget.textRectBlock;
    final isTargetLocationIsLeft = targetA.center.x <= targetB.center.x;

    final distanceX = isTargetLocationIsLeft
        ? (targetB.tl.x - targetA.tr.x).abs()
        : (targetA.tl.x - targetB.tr.x).abs();
    final distanceY = (targetA.center.y - targetB.center.y).abs();
    final boxHeightDifference = (targetA.height - targetB.height).abs();

    final isCombinable =
        distanceX <= 50 && distanceY <= 30 && boxHeightDifference <= 20;

    return isCombinable;
  }

  factory MenuRectBlock.combine(
    MenuRectBlock target,
    MenuRectBlock combineTarget,
  ) {
    final targetA = target.textRectBlock;
    final targetB = combineTarget.textRectBlock;
    final isTargetALeft = targetA.tr.x <= targetB.tl.x;

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
