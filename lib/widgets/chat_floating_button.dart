import 'package:flutter/material.dart';
import '../screens/chat/tawk_chat_screen.dart';

class ChatFloatingButton extends StatefulWidget {
  const ChatFloatingButton({super.key});

  @override
  State<ChatFloatingButton> createState() => _ChatFloatingButtonState();
}

class _ChatFloatingButtonState extends State<ChatFloatingButton>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  bool _isChatOpen = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleChat() async {
    setState(() => _isChatOpen = !_isChatOpen);

    if (_isChatOpen) {
      // Navigate to chat screen
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const TawkChatScreen()))
          .then((_) {
            // Reset state when coming back from chat
            if (mounted) setState(() => _isChatOpen = false);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseScale.value,
            child: FloatingActionButton.extended(
              onPressed: _toggleChat,
              backgroundColor: _isChatOpen
                  ? Colors.grey[600]
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              icon: Icon(_isChatOpen ? Icons.close : Icons.chat, size: 24),
              label: Text(
                _isChatOpen ? 'Close' : 'Chat',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          );
        },
      ),
    );
  }
}
