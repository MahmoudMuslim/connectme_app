import '../../core/result/result.dart';
import '../entities/community_member.dart';
import '../repositories/user_repository.dart';

/// Returns the members plotted on the Community Map.
///
/// The v1 release ships a hardcoded roster spread across four cities
/// (requirement 4); swapping in a Firestore query only means replacing the
/// body of this use case because callers depend on the contract, not on the
/// data source (Open/Closed).
class GetCommunityMembers {
  const GetCommunityMembers(this._repository);

  final UserRepository _repository;

  /// Extra members registered through the app, merged with the seeded roster.
  Future<Result<List<CommunityMember>>> call() async {
    return _repository.getCommunityMembers();
  }
}
