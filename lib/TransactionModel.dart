/// Whether a spend was necessary or not — drives the AI recommendations.
enum Necessity { essential, nonEssential, justWanted }

extension NecessityLabel on Necessity {
  String get labelTh {
    switch (this) {
      case Necessity.essential:
        return 'จำเป็น';
      case Necessity.nonEssential:
        return 'ไม่จำเป็น';
      case Necessity.justWanted:
        return 'อยากได้เฉยๆ';
    }
  }
}

enum TxType { income, expense }

class TransactionModel {
  final String id;
  final double amount;
  final String categoryId;
  final String detail;
  final DateTime date;
  final Necessity necessity;
  final TxType type;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.detail,
    required this.date,
    required this.necessity,
    this.type = TxType.expense,
  });

  TransactionModel copyWith({
    double? amount,
    String? categoryId,
    String? detail,
    DateTime? date,
    Necessity? necessity,
    TxType? type,
  }) {
    return TransactionModel(
      id: id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      detail: detail ?? this.detail,
      date: date ?? this.date,
      necessity: necessity ?? this.necessity,
      type: type ?? this.type,
    );
  }
}