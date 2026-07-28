/// Which Market Maker workflow a screen focuses on.
///
/// `configuration` = spread, limits, save/delete form.
/// `placeOrders` = pair selection + optional overrides + place two-sided orders.
enum MarketMakerScreenMode {
  configuration,
  placeOrders,
}