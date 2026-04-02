double calculateROI({
  required double totalInvested,
  required double totalReturn,
}) {
  return (totalReturn - totalInvested) / totalInvested;
}
