class TornadoTransaction {
  final int index;
  final int timeStamp;
  final String txHash;
  final String action; // 'd' for deposit, 'w' for withdrawal
  final String account;
  final double amount;
  final int gasPrice;

  const TornadoTransaction({
    required this.index,
    required this.timeStamp,
    required this.txHash,
    required this.action,
    required this.account,
    required this.amount,
    required this.gasPrice,
  });

  bool get isDeposit => action == 'd';
  bool get isWithdrawal => action == 'w';

  @override
  String toString() =>
      'TornadoTransaction{index: $index, action: $action, '
      'account: $account, amount: $amount, txHash: $txHash}';
}
