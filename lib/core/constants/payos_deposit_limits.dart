/// Minimum VND amount for PayOS fiat deposit checkout (client-side guard).
///
/// Prefer server validation; align with `GET /deposits` or PayOS config when exposed.
const int kPayosMinAmountVnd = 10000;
