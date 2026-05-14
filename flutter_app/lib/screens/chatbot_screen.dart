import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/chatbot_provider.dart';
import '../providers/posture_provider.dart';
import '../utils/app_localizations.dart';
import '../utils/app_colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with AutomaticKeepAliveClientMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  bool get wantKeepAlive => false;

  @override
  void deactivate() {
    context.read<ChatbotProvider>().stopTts();
    super.deactivate();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    final posture = context.read<PostureProvider>().currentData;
    context
        .read<ChatbotProvider>()
        .sendMessage(text, currentPosture: posture)
        .then((_) => _scrollBottom());
    _scrollBottom();
  }

  void _scrollBottom() => Future.delayed(const Duration(milliseconds: 150), () {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final c = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: c.scaffold,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(c),
      body: Column(children: [
        Expanded(
          child: Consumer<ChatbotProvider>(builder: (_, chat, __) {
            final hasUserMsg = chat.messages.any((m) => m.isUser);
            if (!hasUserMsg) {
              return _WelcomeGrid(onTap: _send, chat: chat);
            }
            return ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: chat.messages.length + (chat.isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == chat.messages.length) return const _TypingIndicator();
                final msg = chat.messages[i];
                if (i == 0 && !msg.isUser) return const SizedBox.shrink();
                return _MessageBubble(msg: msg);
              },
            );
          }),
        ),
        _InputBar(
          controller: _ctrl,
          onSend: _send,
          chat: context.watch<ChatbotProvider>(),
        ),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors c) {
    return AppBar(
      backgroundColor: c.card,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: Row(children: [
        // Logo SpineBot — carré arrondi avec gradient, icône propre
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.primary, c.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.psychology_alt_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SpineBot',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: c.textPrimary)),
            Row(children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Text('Assistant IA actif',
                  style: TextStyle(
                      fontSize: 10,
                      color: c.textMuted,
                      fontWeight: FontWeight.w500)),
            ]),
          ],
        ),
      ]),
      actions: [
        Consumer<ChatbotProvider>(
            builder: (_, cv, __) => _AppBarIconBtn(
                  icon: cv.ttsEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: cv.ttsEnabled ? c.primary : c.textMuted,
                  onTap: cv.toggleTts,
                )),
        _AppBarIconBtn(
          icon: Icons.restart_alt_rounded,
          color: c.textMuted,
          onTap: () => context.read<ChatbotProvider>().clearMessages(),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFF00D4AA).withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

// ─── Bouton icône AppBar ──────────────────────────────────────
class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AppBarIconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ============================================================
// Grille de bienvenue — design pro sans emojis
// ============================================================
class _WelcomeGrid extends StatelessWidget {
  final Function(String) onTap;
  final ChatbotProvider chat;
  const _WelcomeGrid({required this.onTap, required this.chat});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final c = Theme.of(context).extension<AppColors>()!;

    final buttons = [
      _GridItem(Icons.accessibility_new_rounded, loc.myPosture,
          loc.cmdPosture, const Color(0xFF00D4AA)),
      _GridItem(Icons.fitness_center_rounded, loc.exercisesBtn,
          loc.cmdExercise, const Color(0xFF4FC3F7)),
      _GridItem(Icons.lightbulb_outline_rounded, loc.adviceBtn,
          loc.cmdAdvice, const Color(0xFFFFB400)),
      _GridItem(Icons.bar_chart_rounded, loc.reportBtn,
          loc.cmdReport, const Color(0xFFFF6B6B)),
      _GridItem(Icons.timer_outlined, loc.breakBtn,
          loc.cmdBreak, const Color(0xFFB388FF)),
      _GridItem(Icons.tune_rounded, loc.calibrateBtn,
          loc.cmdCalibrate, const Color(0xFF80CBC4)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(children: [
        // ── Logo + texte direct — sans fond coloré ─────────────
        const SizedBox(height: 10),
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00D4AA), Color(0xFF00A884)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF00D4AA).withValues(alpha: 0.30),
                blurRadius: 22,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(Icons.psychology_alt_rounded,
              color: Colors.white, size: 38),
        ),
        const SizedBox(height: 14),
        Text('SpineBot',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: c.textPrimary)),
        const SizedBox(height: 6),
        Text(loc.howCanIHelp,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF8892B0),
                height: 1.4,
                fontWeight: FontWeight.w400)),

        const SizedBox(height: 24),

        // ── Grille 2×3 ────────────────────────────────────────
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: buttons
              .map((item) => _GridButton(item: item, onTap: onTap))
              .toList(),
        ),
      ]),
    );
  }
}

class _GridItem {
  final IconData icon;
  final String label, command;
  final Color color;
  const _GridItem(this.icon, this.label, this.command, this.color);
}

class _GridButton extends StatelessWidget {
  final _GridItem item;
  final Function(String) onTap;
  const _GridButton({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: () => onTap(item.command),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: item.color.withValues(alpha: 0.18), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: item.color.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 3)),
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: item.color.withValues(alpha: 0.15), width: 1),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.label,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                    height: 1.35)),
          ),
        ]),
      ),
    );
  }
}

// ============================================================
// Bulle de message — design épuré professionnel
// ============================================================
class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    final c = Theme.of(context).extension<AppColors>()!;
    final isAlert = msg.type == MessageType.alert;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar IA — cercle gradient discret sans emoji
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.primary, c.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.psychology_alt_rounded,
                  color: Colors.white, size: 15),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.74),
              decoration: BoxDecoration(
                color: isAlert
                    ? const Color(0xFFFF6B6B).withValues(alpha: 0.1)
                    : isUser
                        ? c.primary
                        : c.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isAlert
                            ? const Color(0xFFFF6B6B).withValues(alpha: 0.25)
                            : c.border,
                      ),
                boxShadow: [
                  BoxShadow(
                      color: (isUser ? c.primary : Colors.black)
                          .withValues(alpha: isUser ? 0.2 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: isAlert
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.wifi_off_rounded,
                            size: 13, color: Color(0xFFFF6B6B)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(msg.text,
                            style: const TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontSize: 13,
                                height: 1.5)),
                      ),
                    ])
                  : Text(msg.text,
                      style: TextStyle(
                          color: isUser ? Colors.white : c.textPrimary,
                          fontSize: 14,
                          height: 1.55)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Indicateur de frappe animé
// ============================================================
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [c.primary, c.primaryDark]),
            boxShadow: [
              BoxShadow(
                  color: c.primary.withValues(alpha: 0.2), blurRadius: 6),
            ],
          ),
          child: const Icon(Icons.psychology_alt_rounded,
              color: Colors.white, size: 15),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: c.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _Dot(delay: 0),
            const SizedBox(width: 5),
            _Dot(delay: 180),
            const SizedBox(width: 5),
            _Dot(delay: 360),
          ]),
        ),
      ]),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 580));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(
                const Color(0xFF8892B0), const Color(0xFF00D4AA), _anim.value),
          ),
        ),
      );
}

// ============================================================
// Barre de saisie — design pro raffiné
// ============================================================
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final ChatbotProvider chat;
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final c = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 12, 16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: c.card,
        border: Border(
            top: BorderSide(
                color: const Color(0xFF00D4AA).withValues(alpha: 0.12),
                width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: c.cardInner,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.border),
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(color: c.textPrimary, fontSize: 14),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: loc.typeMessage,
                hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onSubmitted: onSend,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Bouton envoi — rond avec gradient et ombre
        GestureDetector(
          onTap: () => onSend(controller.text),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.primary, c.primaryDark]),
              boxShadow: [
                BoxShadow(
                    color: c.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.arrow_upward_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
