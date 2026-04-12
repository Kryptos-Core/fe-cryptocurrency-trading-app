/// Default max height for treasury chain / filter dropdown menus.
///
/// Previously used a fraction of full screen only (e.g. 35%), which on desktop
/// produced very tall menus inside bottom sheets. This keeps a bounded scroll
/// area with a hard cap.
double defaultTreasuryDropdownMenuMaxHeight(double screenHeight) {
  if (screenHeight.isNaN || screenHeight.isInfinite || screenHeight <= 0) {
    return 220;
  }
  return (screenHeight * 0.26).clamp(168.0, 220.0);
}

/// Tighter menu for small surfaces (e.g. "Tạo ví giao dịch" bottom sheet).
const double kTreasurySheetDropdownMenuMaxHeight = 200;
