


import '../../model/conversation_data_model.dart';

class MessagesState {
  final List<Conversation> conversations;
  final String searchQuery;

  const MessagesState({
    required this.conversations,
    this.searchQuery = '',
  });

  List<Conversation> get filtered {
    if (searchQuery.trim().isEmpty) return conversations;
    final q = searchQuery.toLowerCase();
    return conversations
        .where((c) =>
    c.name.toLowerCase().contains(q) ||
        c.lastMessage.toLowerCase().contains(q))
        .toList();
  }

  MessagesState copyWith({
    List<Conversation>? conversations,
    String? searchQuery,
  }) =>
      MessagesState(
        conversations: conversations ?? this.conversations,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}