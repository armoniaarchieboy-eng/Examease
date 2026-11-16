import 'dart:math';

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// MODEL + PARSER
// ---------------------------------------------------------------------------
class Flashcard {
  final String term;
  final String meaning;
  const Flashcard(this.term, this.meaning);
}

/// Turns reviewer notes into flashcards.
/// One card per line. Supported formats:
///   term : meaning
///   term = meaning
///   term - meaning
/// The EARLIEST separator in the line is used. Lines without one are skipped.
List<Flashcard> parseFlashcards(String content) {
  final cards = <Flashcard>[];
  for (final raw in content.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    int best = -1;
    int sepLen = 1;
    for (final d in [':', '=', ' - ', ' – ']) {
      final i = line.indexOf(d);
      if (i > 0 && (best == -1 || i < best)) {
        best = i;
        sepLen = d.length;
      }
    }
    if (best == -1) continue;

    final term = line.substring(0, best).trim();
    final meaning = line.substring(best + sepLen).trim();
    if (term.isNotEmpty && meaning.isNotEmpty) {
      cards.add(Flashcard(term, meaning));
    }
  }
  return cards;
}

// ---------------------------------------------------------------------------
// MODE PICKER (bottom sheet)
// ---------------------------------------------------------------------------
void showStudyOptions(
  BuildContext context,
  String title,
  List<Flashcard> cards,
  void Function(String) onLog,
) {
  if (cards.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No flashcards found. Write notes as "term : meaning", one per line.',
        ),
      ),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study: $title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${cards.length} card${cards.length == 1 ? '' : 's'} ready',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade50,
                child: const Icon(Icons.style, color: Colors.deepPurple),
              ),
              title: const Text('Flashcards'),
              subtitle: const Text('Flip cards and mark what you know'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FlashcardPage(title: title, cards: cards, onLog: onLog),
                  ),
                );
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade50,
                child: const Icon(Icons.quiz, color: Colors.orange),
              ),
              title: const Text('Quick Quiz'),
              subtitle: const Text('Multiple choice, with a score at the end'),
              onTap: () {
                if (cards.length < 2) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quick Quiz needs at least 2 cards.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuizPage(title: title, cards: cards, onLog: onLog),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// FLASHCARD PAGE
// ---------------------------------------------------------------------------
class FlashcardPage extends StatefulWidget {
  final String title;
  final List<Flashcard> cards;
  final void Function(String) onLog;

  const FlashcardPage({
    super.key,
    required this.title,
    required this.cards,
    required this.onLog,
  });

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  late List<Flashcard> deck;
  final List<Flashcard> missed = [];
  int index = 0;
  int known = 0;
  bool flipped = false;

  @override
  void initState() {
    super.initState();
    deck = [...widget.cards];
  }

  void restart(List<Flashcard> cards, {bool shuffle = true}) {
    setState(() {
      deck = [...cards];
      if (shuffle) deck.shuffle(Random());
      missed.clear();
      index = 0;
      known = 0;
      flipped = false;
    });
  }

  void answer(bool gotIt) {
    setState(() {
      if (gotIt) {
        known++;
      } else {
        missed.add(deck[index]);
      }
      flipped = false;
      index++;
    });
    if (index >= deck.length) {
      widget.onLog('Flashcards: ${widget.title} ($known/${deck.length} known)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final finished = index >= deck.length;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1FF),
      appBar: AppBar(
        title: Text(
          'Flashcards • ${widget.title}',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Shuffle & restart',
            icon: const Icon(Icons.shuffle),
            onPressed: () => restart(widget.cards),
          ),
        ],
      ),
      body: finished ? resultView() : cardView(),
    );
  }

  Widget cardView() {
    final c = deck[index];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Card ${index + 1} of ${deck.length}'),
              Text('✅ $known   🔁 ${missed.length}'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: index / deck.length,
              minHeight: 8,
              color: Colors.deepPurple,
              backgroundColor: Colors.deepPurple.shade50,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => flipped = !flipped),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Container(
                  key: ValueKey('${flipped ? 'back' : 'front'}$index'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: flipped
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: flipped ? Colors.white : null,
                    borderRadius: BorderRadius.circular(24),
                    border: flipped
                        ? Border.all(color: Colors.deepPurple, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            flipped ? 'MEANING' : 'TERM',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 1.4,
                              color: flipped
                                  ? Colors.deepPurple
                                  : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            flipped ? c.meaning : c.term,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: flipped ? Colors.black87 : Colors.white,
                            ),
                          ),
                          if (!flipped) ...[
                            const SizedBox(height: 20),
                            const Text(
                              'Tap to flip',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (!flipped)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => setState(() => flipped = true),
                child: const Text('SHOW ANSWER'),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => answer(false),
                      icon: const Icon(Icons.replay),
                      label: const Text('REVIEW AGAIN'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => answer(true),
                      icon: const Icon(Icons.check),
                      label: const Text('GOT IT'),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget resultView() {
    final total = deck.length;
    return _ResultView(
      emoji: missed.isEmpty ? '🎉' : '💪',
      headline: missed.isEmpty ? 'All cards known!' : 'Round complete',
      detail: '$known of $total cards known',
      percent: total == 0 ? 0 : known / total,
      onRetryMissed: missed.isEmpty
          ? null
          : () => restart(List.of(missed), shuffle: true),
      onRestart: () => restart(widget.cards),
    );
  }
}

// ---------------------------------------------------------------------------
// QUICK QUIZ PAGE
// ---------------------------------------------------------------------------
class QuizPage extends StatefulWidget {
  final String title;
  final List<Flashcard> cards;
  final void Function(String) onLog;

  const QuizPage({
    super.key,
    required this.title,
    required this.cards,
    required this.onLog,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _rng = Random();
  late List<Flashcard> questions;
  late List<List<String>> options;
  int index = 0;
  int score = 0;
  String? selected;

  @override
  void initState() {
    super.initState();
    newRound();
  }

  void newRound() {
    questions = [...widget.cards]..shuffle(_rng);
    options = questions.map(buildOptions).toList();
    index = 0;
    score = 0;
    selected = null;
  }

  List<String> buildOptions(Flashcard q) {
    final others =
        widget.cards
            .map((c) => c.meaning)
            .where((m) => m != q.meaning)
            .toSet()
            .toList()
          ..shuffle(_rng);
    final opts = <String>[q.meaning, ...others.take(3)]..shuffle(_rng);
    return opts;
  }

  void pick(String option) {
    if (selected != null) return;
    setState(() {
      selected = option;
      if (option == questions[index].meaning) score++;
    });
  }

  void next() {
    setState(() {
      index++;
      selected = null;
    });
    if (index >= questions.length) {
      widget.onLog('Quick Quiz: ${widget.title} ($score/${questions.length})');
    }
  }

  @override
  Widget build(BuildContext context) {
    final finished = index >= questions.length;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1FF),
      appBar: AppBar(
        title: Text(
          'Quick Quiz • ${widget.title}',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: finished
          ? _ResultView(
              emoji: score == questions.length ? '🏆' : '📚',
              headline: 'Quiz complete',
              detail: 'You scored $score / ${questions.length}',
              percent: score / questions.length,
              onRetryMissed: null,
              onRestart: () => setState(newRound),
            )
          : quizView(),
    );
  }

  Widget quizView() {
    final q = questions[index];
    final opts = options[index];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${index + 1} of ${questions.length}'),
            Text('Score: $score'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: index / questions.length,
            minHeight: 8,
            color: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.shade50,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text(
                'What is the meaning of:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                q.term,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...opts.map((o) {
          final isCorrect = o == q.meaning;
          final isSelected = o == selected;
          Color bg = Colors.white;
          Color border = Colors.grey.shade300;
          IconData? icon;
          if (selected != null) {
            if (isCorrect) {
              bg = Colors.green.shade50;
              border = Colors.green;
              icon = Icons.check_circle;
            } else if (isSelected) {
              bg = Colors.red.shade50;
              border = Colors.red;
              icon = Icons.cancel;
            }
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: border, width: 1.5),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => pick(o),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: Text(o)),
                      if (icon != null)
                        Icon(
                          icon,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        if (selected != null)
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: next,
              child: Text(
                index == questions.length - 1 ? 'FINISH' : 'NEXT',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED RESULT VIEW
// ---------------------------------------------------------------------------
class _ResultView extends StatelessWidget {
  final String emoji;
  final String headline;
  final String detail;
  final double percent;
  final VoidCallback? onRetryMissed;
  final VoidCallback onRestart;

  const _ResultView({
    required this.emoji,
    required this.headline,
    required this.detail,
    required this.percent,
    required this.onRetryMissed,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 54)),
              const SizedBox(height: 12),
              Text(
                headline,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(detail, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 12,
                  color: Colors.deepPurple,
                  backgroundColor: Colors.deepPurple.shade50,
                ),
              ),
              const SizedBox(height: 6),
              Text('${(percent * 100).round()}%'),
              const SizedBox(height: 22),
              if (onRetryMissed != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onRetryMissed,
                    icon: const Icon(Icons.replay),
                    label: const Text('RETRY MISSED CARDS'),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('SHUFFLE & RESTART'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
