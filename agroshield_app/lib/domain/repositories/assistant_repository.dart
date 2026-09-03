abstract class AssistantRepository {
  /// Returns a grounded answer to [question].
  ///
  /// Optional parameters:
  /// - [lastClassName]: TFLite class name from the most recent scan.
  /// - [conversationHistory]: Prior turns (role → content) for context.
  /// - [scanContext]: Free-text summary of the latest scan results.
  Future<String> answer(
    String question, {
    String? lastClassName,
    List<Map<String, String>>? conversationHistory,
    String? scanContext,
  });
}
