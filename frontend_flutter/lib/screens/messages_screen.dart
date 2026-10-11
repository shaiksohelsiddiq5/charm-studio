import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/message_model.dart';
import '../theme/app_colors.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showMobileThread = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(AppState appState) async {
    final text = _textController.text.trim();
    if (text.isEmpty || appState.isSendingMessage) return;

    final draft = text;
    _textController.clear();
    appState.clearSuggestedReply();

    final success = await appState.sendMessage(draft);
    if (!mounted) return;

    if (success) {
      _scrollToBottom();
    } else {
      _textController.text = draft;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.messageError ?? 'Failed to send message. Draft restored.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleSuggestReply(AppState appState) async {
    final activeConv = appState.activeConversation;
    if (activeConv == null || appState.isSuggestingReply) return;

    final suggestion = await appState.getSuggestedReply(activeConv.id);
    if (!mounted) return;

    if (suggestion != null && suggestion.isNotEmpty) {
      setState(() {
        _textController.text = suggestion;
        _textController.selection = TextSelection.collapsed(offset: suggestion.length);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                appState.suggestedReplySource == 'gemini' ? Icons.auto_awesome : Icons.lightbulb_outline,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  appState.suggestedReplySource == 'gemini'
                      ? 'AI reply suggested by Gemini. Review & edit before sending.'
                      : 'Reply suggested by template engine. Review & edit before sending.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleSimulateReply(AppState appState) async {
    final success = await appState.triggerSimulatedReply();
    if (!mounted) return;

    if (success) {
      _scrollToBottom();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simulated creator response received.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final conversations = appState.conversations;
    final activeConv = appState.activeConversation;
    final messages = appState.messages;
    final isDesktop = MediaQuery.of(context).size.width >= 860;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: isDesktop ? 24 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Direct Creator Messages',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Active as: ${appState.currentUser.name} (${appState.currentUser.isBrand ? "Brand" : "Creator"})',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (activeConv != null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => appState.loadConversations(),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isDesktop
                    ? Row(
                        children: [
                          _buildConversationList(appState, conversations, activeConv, width: 320),
                          const VerticalDivider(width: 1, color: AppColors.borderLight),
                          Expanded(
                            child: _buildChatThread(appState, activeConv, messages, isDesktop: true),
                          ),
                        ],
                      )
                    : (_showMobileThread && activeConv != null)
                        ? _buildChatThread(appState, activeConv, messages, isDesktop: false)
                        : _buildConversationList(appState, conversations, activeConv),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(
    AppState appState,
    List<Conversation> conversations,
    Conversation? activeConv, {
    double? width,
  }) {
    if (conversations.isEmpty) {
      return Container(
        width: width,
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text(
              'No Conversations Yet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select a creator from Discovery or Shortlist to initiate a message thread.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => appState.navigateTo('discovery'),
              child: const Text('Browse Creators'),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.white,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Conversations',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${conversations.length}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                final isSelected = activeConv?.id == conv.id;
                final otherPart = conv.getOtherParticipant(appState.currentUser.id);

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: AppColors.primaryLight.withValues(alpha: 0.6),
                  onTap: () {
                    appState.selectConversation(conv);
                    setState(() {
                      _showMobileThread = true;
                    });
                    _scrollToBottom();
                  },
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: otherPart.avatar.isNotEmpty ? NetworkImage(otherPart.avatar) : null,
                    child: otherPart.avatar.isEmpty
                        ? Text(
                            otherPart.name.isNotEmpty ? otherPart.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          )
                        : null,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherPart.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTimestamp(conv.lastMessageTime),
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        conv.campaignTitle,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conv.lastMessageText.isNotEmpty ? conv.lastMessageText : 'No messages yet',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: conv.unreadCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildChatThread(
    AppState appState,
    Conversation? activeConv,
    List<Message> messages, {
    required bool isDesktop,
  }) {
    if (activeConv == null) {
      return Container(
        color: AppColors.background,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text(
              'No conversation selected',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose a creator from the left to start reviewing deliverables and discussing milestones.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final otherPart = activeConv.getOtherParticipant(appState.currentUser.id);

    return Column(
      children: [
        // Thread Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            children: [
              if (!isDesktop) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  tooltip: 'All Conversations',
                  onPressed: () => setState(() => _showMobileThread = false),
                ),
                const SizedBox(width: 4),
              ],
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: otherPart.avatar.isNotEmpty ? NetworkImage(otherPart.avatar) : null,
                child: otherPart.avatar.isEmpty
                    ? Text(
                        otherPart.name.isNotEmpty ? otherPart.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            otherPart.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: otherPart.role == 'creator' ? AppColors.purpleLight : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            otherPart.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: otherPart.role == 'creator' ? AppColors.purpleDark : AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Campaign: ${activeConv.campaignTitle}',
                      style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Simulation trigger button for hackathon demo
              OutlinedButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                label: Text(
                  isDesktop ? 'Simulate Reply' : 'Reply',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: () => _handleSimulateReply(appState),
              ),

              const SizedBox(width: 8),

              // Escrow Action Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Offer terms and milestone escrow dispatched for ${otherPart.name}!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: Text(isDesktop ? 'Hire & Escrow' : 'Hire', style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        // Message List
        Expanded(
          child: Container(
            color: AppColors.background,
            child: appState.isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: AppColors.textMuted),
                            const SizedBox(height: 8),
                            const Text('No messages in this conversation yet.', style: TextStyle(color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            Text('Send a message to ${otherPart.name} to begin!', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderId == appState.currentUser.id;
                          return _buildMessageBubble(msg, isMe: isMe);
                        },
                      ),
          ),
        ),

        // Message Input Area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Actions Toolbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: appState.isSuggestingReply
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                          )
                        : const Icon(Icons.auto_awesome, size: 13, color: AppColors.primary),
                    label: Text(
                      appState.isSuggestingReply
                          ? 'Generating AI Reply...'
                          : (isDesktop ? 'AI Suggest Reply (Gemini)' : 'AI Suggest Reply'),
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      minimumSize: const Size(0, 28),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: appState.isSuggestingReply ? null : () => _handleSuggestReply(appState),
                  ),

                  if (appState.suggestedReply != null && _textController.text.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.clear_rounded, size: 12, color: AppColors.textMuted),
                      label: const Text('Clear Draft', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        minimumSize: const Size(0, 26),
                      ),
                      onPressed: () {
                        _textController.clear();
                        appState.clearSuggestedReply();
                      },
                    ),
                ],
              ),

              const SizedBox(height: 6),

              // Suggestion Status Banner
              if (appState.suggestedReply != null && _textController.text.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: appState.suggestedReplySource == 'gemini'
                        ? AppColors.purpleLight
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: appState.suggestedReplySource == 'gemini'
                          ? AppColors.purpleDark.withValues(alpha: 0.25)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        appState.suggestedReplySource == 'gemini' ? Icons.auto_awesome : Icons.lightbulb_outline,
                        size: 12,
                        color: appState.suggestedReplySource == 'gemini' ? AppColors.purpleDark : const Color(0xFFB45309),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          appState.suggestedReplySource == 'gemini'
                              ? '✨ AI suggestion generated via Gemini. Edit freely before sending.'
                              : '💡 Heuristic suggestion loaded. Edit freely before sending.',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: appState.suggestedReplySource == 'gemini' ? AppColors.purpleDark : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Text Field and Send Button Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(appState),
                      decoration: InputDecoration(
                        hintText: 'Type your message or edit suggested reply...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  appState.isSendingMessage
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                          tooltip: 'Send Message',
                          onPressed: () => _handleSend(appState),
                        ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Message msg, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender header if not me
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.senderName,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    if (msg.isSimulatedReply) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.purpleLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.purpleDark.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 10, color: AppColors.purpleDark),
                            SizedBox(width: 3),
                            Text(
                              'AI Demo Simulation',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.purpleDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(msg.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white.withValues(alpha: 0.7) : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
