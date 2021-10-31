///
/// Object witch provides optional operators to query Firebase
/// * field parameter is mandatory. It's the name of the property where you
/// put a condition.
///
/// * All the others parameters are optional but you need to provide at least one.
class FirebaseQueryCondition {
  FirebaseQueryCondition(
      this.field, {
        this.isEqualTo,
        this.isNotEqualTo,
        this.isLessThan,
        this.isLessThanOrEqualTo,
        this.isGreaterThan,
        this.isGreaterThanOrEqualTo,
        this.arrayContains,
        this.arrayContainsAny,
        this.whereIn,
        this.whereNotIn,
        this.isNull,
      });

  dynamic field;
  dynamic isEqualTo;
  dynamic isNotEqualTo;
  dynamic isLessThan;
  dynamic isLessThanOrEqualTo;
  dynamic isGreaterThan;
  dynamic isGreaterThanOrEqualTo;
  dynamic arrayContains;
  dynamic arrayContainsAny;
  dynamic whereIn;
  dynamic whereNotIn;
  dynamic isNull;
}