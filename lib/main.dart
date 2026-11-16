import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  AuthService.init();
  runApp(const MyApp());
}

// ============================ THEME ============================
const kPurple = Color(0xFF7C3AED);
const kPink = Color(0xFFC026D3);
const kInk = Color(0xFF1E1233);
const kMuted = Color(0xFF6B5F80);
const kRed = Color(0xFFB3261E);
const kGreen = Color(0xFF1B6B3A);
const kTile1 = Color(0xFFF5D9F7);
const kTile2 = Color(0xFFE4D5F8);
const kGrad = LinearGradient(colors: [kPurple, kPink]);
const kDeep = LinearGradient(colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)]);
const kBg = LinearGradient(
  colors: [Color(0xFFE4D8FA), Color(0xFFF8F5FF)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// ============================ MODELS ============================
class QCard {
  final String topic, q;
  final List<String> o;
  final int a;
  QCard(this.topic, this.q, this.o, this.a);
}

class Exam {
  String subject, room;
  DateTime date;
  TimeOfDay time;
  List<String> coverage;
  Exam(this.subject, this.room, this.date, this.time, [this.coverage = const []]);
}

class StudyTask {
  String subject, topic;
  DateTime date;
  TimeOfDay time;
  bool done, repeat;
  StudyTask(this.subject, this.topic, this.date, this.time,
      {this.done = false, this.repeat = false});
}

class Reviewer {
  String subject, title, file, size;
  int? score; // null = not studied yet
  List<QCard> cards;
  Reviewer(this.subject, this.title, this.file, this.size, this.cards, [this.score]);
}

class ActivityLog {
  final String title, sub;
  final IconData icon;
  final DateTime time = DateTime.now();
  ActivityLog(this.title, this.sub, this.icon);
}

class Student {
  final String idNumber;
  String last, first, middle, suffix, phone, email, school, course, password;
  int year;
  final DateTime joined = DateTime.now();
  final exams = <Exam>[];
  final tasks = <StudyTask>[];
  final reviewers = <Reviewer>[];
  final activity = <ActivityLog>[];
  bool reminders = true, dark = false;

  Student({
    required this.idNumber,
    required this.last,
    required this.first,
    required this.password,
    this.middle = '',
    this.suffix = 'None',
    this.phone = '',
    this.email = '',
    this.school = '',
    this.course = '',
    this.year = 1,
  });

  String get fullName => '$first $last';
  String get initials =>
      ((first.isEmpty ? '' : first[0]) + (last.isEmpty ? '' : last[0])).toUpperCase();
  void log(String t, String sub, IconData i) => activity.add(ActivityLog(t, sub, i));
}

List<String> subjectsOf(Student s) => {
      ...s.exams.map((e) => e.subject),
      ...s.tasks.map((e) => e.subject),
      ...s.reviewers.map((e) => e.subject),
    }.toList()
      ..sort();

int subjectProgress(Student s, String subject) {
  final sc = s.reviewers
      .where((r) => r.subject == subject && r.score != null)
      .map((r) => r.score!)
      .toList();
  return sc.isEmpty ? 0 : (sc.reduce((a, b) => a + b) / sc.length).round();
}

// Placeholder "AI" generator. Replace with a real AI/API call later.
List<QCard> genCards(String topic) {
  final cards = <QCard>[];
  if (topic.toLowerCase().contains('derivative')) {
    cards.addAll([
      QCard('Power rule', 'What is the Power rule?',
          ['d/dx xⁿ = n·xⁿ⁻¹', 'd/dx xⁿ = xⁿ⁺¹', 'd/dx xⁿ = n·x', 'd/dx xⁿ = xⁿ/n'], 0),
      QCard('Product rule', 'Which formula is the Product rule?',
          ["d/dx xⁿ = n·xⁿ⁻¹", "(uv)' = u'v'", "(uv)' = u'v + uv'", "(u/v)' = u'/v'"], 2),
      QCard('Quotient rule', 'Which formula is the Quotient rule?',
          ["(u/v)' = u'/v'", "(u/v)' = (u'v − uv')/v²", "(u/v)' = u'v + uv'", "(u/v)' = (uv' − u'v)/v²"], 1),
      QCard('Chain rule', 'What is the Chain rule?',
          ["f(g(x))' = f'(x)·g'(x)", "f(g(x))' = f'(g(x))·g'(x)", "f(g(x))' = f(g'(x))", "f(g(x))' = f'(g(x))"], 1),
      QCard('Constant rule', 'What is the derivative of a constant?', ['1', 'The constant', '0', 'x'], 2),
    ]);
  }
  var n = 1;
  while (cards.length < 8) {
    cards.add(QCard('$topic: key idea $n', 'Key idea $n of "$topic"?',
        ['Option A', 'Option B', 'Option C', 'Option D'], n % 4));
    n++;
  }
  return cards;
}

// ============================ AUTH ============================
class AuthService {
  static const int idLength = 10;
  static final Map<String, Student> students = {};
  static bool isValidId(String id) => id.length == idLength && RegExp(r'^\d+$').hasMatch(id);

  static void init() {
    final n = DateTime.now();
    final t = DateTime(n.year, n.month, n.day);
    final s = Student(
      idNumber: '1015140001',
      first: 'Juan',
      last: 'Dela Cruz',
      middle: 'Santos',
      password: '1234',
      school: 'Demo University',
      course: 'BS Information Technology',
      year: 3,
    );
    s.exams.addAll([
      Exam('Mathematics', 'Room 201', t.add(const Duration(days: 3)),
          const TimeOfDay(hour: 9, minute: 0), ['Derivative rules', 'Integrals']),
      Exam('Programming 2', 'Computer Lab 1', t.add(const Duration(days: 6)),
          const TimeOfDay(hour: 13, minute: 30), ['Flutter basics']),
    ]);
    s.tasks.addAll([
      StudyTask('Mathematics', 'Derivatives practice problems', t,
          const TimeOfDay(hour: 19, minute: 0), repeat: true),
      StudyTask('Programming 2', 'Review Flutter widgets', t,
          const TimeOfDay(hour: 20, minute: 30), done: true),
    ]);
    s.reviewers.addAll([
      Reviewer('Mathematics', 'Derivative rules', 'derivatives.pdf', '1.2 MB',
          genCards('Derivative rules'), 75),
      Reviewer('Programming 2', 'Flutter basics', 'flutter-notes.docx', '480 KB',
          genCards('Flutter basics'), 100),
    ]);
    s.log('Account created', 'Welcome to ExamEase', Icons.person_add_alt_1);
    students[s.idNumber] = s;
  }
}

// ============================ HELPERS ============================
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _fullMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';
bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
bool scheduleHasPassed(DateTime d, TimeOfDay t, DateTime now) =>
    DateTime(d.year, d.month, d.day, t.hour, t.minute).isBefore(now);

void toast(BuildContext c, String m, {bool err = false}) =>
    ScaffoldMessenger.of(c).showSnackBar(
        SnackBar(content: Text(m), backgroundColor: err ? Colors.red : null));

Future<String?> askText(BuildContext c, String title) {
  final ctl = TextEditingController();
  return showDialog<String>(
    context: c,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: ctl, autofocus: true, textCapitalization: TextCapitalization.words),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, ctl.text.trim()), child: const Text('Add')),
      ],
    ),
  );
}

InputDecoration deco(String hint, {IconData? icon, Widget? suffix}) {
  final b = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: Color(0xFFDCCFF2)),
  );
  return InputDecoration(
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon, color: kMuted),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: b,
    enabledBorder: b,
    focusedBorder: b.copyWith(borderSide: const BorderSide(color: kPurple, width: 1.6)),
  );
}

Widget labeled(String l, Widget w) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l, style: const TextStyle(fontWeight: FontWeight.bold, color: kInk)),
        const SizedBox(height: 6),
        w,
      ]),
    );

Widget gBtn(String t, VoidCallback f, {IconData? icon, double h = 54}) => GestureDetector(
      onTap: f,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          gradient: kGrad,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: kPurple.withValues(alpha: .25), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
            Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
        ),
      ),
    );

Widget oBtn(String t, VoidCallback f, {IconData? icon, Color color = kPurple, double h = 54}) =>
    SizedBox(
      height: h,
      child: OutlinedButton.icon(
        onPressed: f,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, color: color, size: 20),
        label: Text(t, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: color, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );

Widget pill(String t, Color bg, Color fg, {IconData? icon}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
        Text(t, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    );

Widget repeatPill() => pill('REPEAT TOPIC', const Color(0xFFFBE5E2), kRed, icon: Icons.flag_outlined);
Widget understoodPill() => pill('Understood', const Color(0xFFDDF3E4), kGreen);

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = Colors.white});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: kPurple.withValues(alpha: .06), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: child,
      );
}

class Bg extends StatelessWidget {
  final Widget child;
  const Bg({super.key, required this.child});
  @override
  Widget build(BuildContext context) =>
      Container(decoration: const BoxDecoration(gradient: kBg), child: child);
}

Widget circBtn(IconData i, VoidCallback f) => GestureDetector(
      onTap: f,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(i, color: kPurple, size: 22),
      ),
    );

Widget logo({double size = 80}) => Column(children: [
      Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(gradient: kGrad, shape: BoxShape.circle),
        child: Icon(Icons.school_rounded, color: Colors.white, size: size * .55),
      ),
      const SizedBox(height: 10),
      RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
          children: [
            TextSpan(text: 'Exam', style: TextStyle(color: Color(0xFF4C1D95))),
            TextSpan(text: 'Ease', style: TextStyle(color: kPink)),
          ],
        ),
      ),
      const Text('— Study smarter —', style: TextStyle(color: kMuted, letterSpacing: 1.2)),
    ]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ExamEase',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: const LoginPage(),
      );
}

// ============================ LOGIN ============================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final id = TextEditingController(), pw = TextEditingController();
  bool hide = true;

  void login() {
    final i = id.text.trim();
    if (i.isEmpty || pw.text.isEmpty) return toast(context, 'Please enter your ID number and password.');
    if (!AuthService.isValidId(i)) {
      return toast(context, 'Invalid ID number. It must be exactly ${AuthService.idLength} digits.', err: true);
    }
    final s = AuthService.students[i];
    if (s == null || s.password != pw.text) return toast(context, 'Incorrect ID number or password.', err: true);
    s.log('Logged in', 'Welcome back', Icons.login);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage(student: s)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Bg(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(children: [
                    logo(),
                    const SizedBox(height: 24),
                    const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kInk)),
                    const Text('Log in to continue studying', style: TextStyle(color: kMuted)),
                    const SizedBox(height: 24),
                    labeled(
                      'ID Number',
                      TextField(
                        controller: id,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(AuthService.idLength)],
                        decoration: deco('Enter your ID number', icon: Icons.badge_outlined),
                      ),
                    ),
                    labeled(
                      'Password',
                      TextField(
                        controller: pw,
                        obscureText: hide,
                        onSubmitted: (_) => login(),
                        decoration: deco('Enter your password',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => hide = !hide),
                            )),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => toast(context, 'Please contact your school admin to reset your password.'),
                        child: const Text('Forgot password?', style: TextStyle(color: kPink, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    gBtn('Log in', login),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .6), borderRadius: BorderRadius.circular(16)),
                      child: const Text('Demo student: ID 1015140001 • Password 1234', textAlign: TextAlign.center, style: TextStyle(color: kMuted)),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                      child: const Text.rich(TextSpan(text: "Don't have an account? ", style: TextStyle(color: kMuted), children: [
                        TextSpan(text: 'Create an account', style: TextStyle(color: kPink, fontWeight: FontWeight.bold)),
                      ])),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

// ============================ REGISTER ============================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final last = TextEditingController(), first = TextEditingController(), middle = TextEditingController();
  final phone = TextEditingController(), email = TextEditingController();
  final school = TextEditingController(), course = TextEditingController();
  final id = TextEditingController(), pw = TextEditingController(), cf = TextEditingController();
  String suffix = 'None';
  int year = 1;
  bool h1 = true, h2 = true;

  Widget section(String t) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 10),
        child: Text(t, style: const TextStyle(color: kPurple, fontWeight: FontWeight.bold, fontSize: 16)),
      );

  void register() {
    if (last.text.trim().isEmpty || first.text.trim().isEmpty || school.text.trim().isEmpty ||
        course.text.trim().isEmpty || id.text.isEmpty || pw.text.isEmpty || cf.text.isEmpty) {
      return toast(context, 'Please complete all required fields.');
    }
    if (email.text.trim().isNotEmpty && !email.text.contains('@')) return toast(context, 'Enter a valid email.', err: true);
    if (!AuthService.isValidId(id.text)) return toast(context, 'ID number must be exactly ${AuthService.idLength} digits.', err: true);
    if (AuthService.students.containsKey(id.text)) return toast(context, 'This ID number is already registered.', err: true);
    if (pw.text.length < 4) return toast(context, 'Password must be at least 4 characters.');
    if (pw.text != cf.text) return toast(context, 'Passwords do not match.');
    final s = Student(
      idNumber: id.text, last: last.text.trim(), first: first.text.trim(), middle: middle.text.trim(),
      suffix: suffix, phone: phone.text.trim(), email: email.text.trim(), school: school.text.trim(),
      course: course.text.trim(), year: year, password: pw.text,
    );
    s.log('Account created', 'Welcome to ExamEase', Icons.person_add_alt_1);
    AuthService.students[id.text] = s;
    Navigator.pop(context);
    toast(context, 'Account created! You can now log in.');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Bg(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Center(child: logo(size: 56)),
                    const SizedBox(height: 14),
                    const Center(child: Text('Create account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kInk))),
                    const Center(child: Text('Start planning your exams', style: TextStyle(color: kMuted))),
                    const SizedBox(height: 16),
                    section('Personal information'),
                    Row(children: [
                      Expanded(child: labeled('Last name', TextField(controller: last, decoration: deco('Dela Cruz')))),
                      const SizedBox(width: 12),
                      Expanded(child: labeled('First name', TextField(controller: first, decoration: deco('Juan')))),
                    ]),
                    Row(children: [
                      Expanded(flex: 3, child: labeled('Middle name', TextField(controller: middle, decoration: deco('Santos')))),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: labeled('Suffix', DropdownButtonFormField<String>(
                          value: suffix,
                          decoration: deco(''),
                          items: ['None', 'Jr.', 'Sr.', 'II', 'III'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => suffix = v ?? 'None'),
                        )),
                      ),
                    ]),
                    labeled('Phone number', TextField(controller: phone, keyboardType: TextInputType.phone, decoration: deco('+63 9XX XXX XXXX', icon: Icons.smartphone))),
                    labeled('Email', TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: deco('name@gmail.com', icon: Icons.mail_outline))),
                    section('School information'),
                    labeled('School', TextField(controller: school, decoration: deco('Enter your school', icon: Icons.school_outlined))),
                    labeled('Course', TextField(controller: course, decoration: deco('e.g. BS Information Technology', icon: Icons.menu_book_outlined))),
                    labeled('Year level', Row(children: [
                      for (final y in [1, 2, 3, 4])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => year = y),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: year == y ? kTile2 : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: year == y ? kPurple : const Color(0xFFDCCFF2), width: 1.4),
                                ),
                                child: Text(['1st', '2nd', '3rd', '4th'][y - 1],
                                    style: TextStyle(fontWeight: FontWeight.bold, color: year == y ? kPurple : kMuted)),
                              ),
                            ),
                          ),
                        ),
                    ])),
                    section('Account'),
                    labeled('ID Number', TextField(
                      controller: id,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(AuthService.idLength)],
                      decoration: deco('Enter your ID number', icon: Icons.badge_outlined),
                    )),
                    labeled('Password', TextField(
                      controller: pw, obscureText: h1,
                      decoration: deco('Create a password', icon: Icons.lock_outline,
                          suffix: IconButton(icon: Icon(h1 ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => h1 = !h1))),
                    )),
                    labeled('Confirm password', TextField(
                      controller: cf, obscureText: h2,
                      decoration: deco('Re-enter your password', icon: Icons.lock_outline,
                          suffix: IconButton(icon: Icon(h2 ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => h2 = !h2))),
                    )),
                    const SizedBox(height: 8),
                    gBtn('Create account', register),
                    const SizedBox(height: 18),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text.rich(TextSpan(text: 'Already have an account? ', style: TextStyle(color: kMuted), children: [
                          TextSpan(text: 'Log in', style: TextStyle(color: kPink, fontWeight: FontWeight.bold)),
                        ])),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

// ============================ DASHBOARD ============================
class DashboardPage extends StatefulWidget {
  final Student student;
  const DashboardPage({super.key, required this.student});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int tab = 0;
  late DateTime sel;
  Student get s => widget.student;
  DateTime get today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    sel = today;
  }

  void refresh() => setState(() {});
  Future<void> go(Widget p) => Navigator.push(context, MaterialPageRoute(builder: (_) => p)).then((_) => refresh());

  void logout() {
    s.log('Logged out', 'See you soon', Icons.logout);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
  }

  void quickQuiz() {
    if (s.reviewers.isEmpty) return toast(context, 'Add a reviewer first.');
    setState(() => tab = 3);
    toast(context, 'Pick a topic and tap Take Quiz.');
  }

  void menu() {
    Widget item(IconData i, String t, String sub, Color bg, VoidCallback f, BuildContext c) => InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(c);
            f();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)), child: Icon(i, color: kPink)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: kInk)),
                Text(sub, style: const TextStyle(color: kMuted)),
              ])),
            ]),
          ),
        );
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (c) => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 70, right: 16),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              width: 330,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('SHORTCUTS', style: TextStyle(color: kMuted, fontWeight: FontWeight.bold, letterSpacing: 1.4)),
                  const SizedBox(height: 8),
                  item(Icons.event_note_outlined, 'Add Exam', 'Date, time, coverage', kTile1, () => go(AddExamPage(student: s)), c),
                  item(Icons.auto_stories_outlined, 'Add Study session', 'Topic, date, reminder', kTile2, () => go(AddStudyPage(student: s, date: sel)), c),
                  item(Icons.layers_outlined, 'Add Reviewer', 'Upload your study file', kTile2, () => go(AddReviewerPage(student: s)), c),
                  item(Icons.layers_outlined, 'Flashcards', 'Study with your cards', kTile1, () => setState(() => tab = 3), c),
                  item(Icons.bolt, 'Quick Quiz', 'Answer cards, get a score', kTile1, quickQuiz, c),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget header(String title, String sub) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: kInk)),
            Text(sub, style: const TextStyle(color: kMuted, fontSize: 15)),
          ])),
          circBtn(Icons.more_vert, menu),
          const SizedBox(width: 8),
          circBtn(Icons.notifications_none, () => toast(context, 'No new reminders.')),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final upcoming = s.exams.where((e) => !e.date.isBefore(today)).length;
    final titles = [
      ['ExamEase', 'Study smarter'],
      ['Exam Schedule', '$upcoming upcoming exams'],
      ['Study Planner', 'Plan your study sessions'],
      ['Reviewers', '${subjectsOf(s).where((x) => s.reviewers.any((r) => r.subject == x)).length} subjects • AI study tools'],
      ['Profile', 'Your account'],
    ];
    final pages = [homeTab(), examTab(), studyTab(), reviewerTab(), profileTab()];
    return Scaffold(
      body: Bg(child: SafeArea(child: Column(children: [header(titles[tab][0], titles[tab][1]), Expanded(child: pages[tab])]))),
      floatingActionButton: (tab == 1 || tab == 3)
          ? GestureDetector(
              onTap: () => go(tab == 1 ? AddExamPage(student: s) : AddReviewerPage(student: s)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(22)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.add, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(tab == 1 ? 'Add Exam' : 'Add Reviewer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: kTile1,
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: kPink), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today, color: kPink), label: 'Exams'),
              NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book, color: kPink), label: 'Study'),
              NavigationDestination(icon: Icon(Icons.layers_outlined), selectedIcon: Icon(Icons.layers, color: kPink), label: 'Reviewer'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: kPink), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- shared small widgets ----------
  Widget tile(IconData i, String v, String l, Color bg) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .8), borderRadius: BorderRadius.circular(12)), child: Icon(i, color: kPink, size: 20)),
          const SizedBox(height: 14),
          Text(v, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kInk)),
          Text(l, style: const TextStyle(color: kMuted)),
        ]),
      );

  Widget bar(int pct, {Color color = Colors.white, Color back = const Color(0x55FFFFFF)}) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(value: pct / 100, minHeight: 8, color: color, backgroundColor: back),
      );

  Widget section(String t, {String? action, VoidCallback? onAction}) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk)),
          if (action != null) GestureDetector(onTap: onAction, child: Text(action, style: const TextStyle(color: kPink, fontWeight: FontWeight.bold))),
        ]),
      );

  Widget examCard(Exam e, {bool deep = false}) {
    final p = subjectProgress(s, e.subject);
    final days = e.date.difference(today).inDays;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: deep ? kDeep : kGrad, borderRadius: BorderRadius.circular(28)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(e.subject, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800))),
          pill(days < 0 ? 'Done' : days == 0 ? 'Today' : '$days days left', Colors.white24, Colors.white),
        ]),
        const SizedBox(height: 6),
        Text('${_months[e.date.month - 1]} ${e.date.day} • ${e.time.format(context)} • ${e.room}', style: const TextStyle(color: Colors.white70)),
        if (e.coverage.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Coverage: ${e.coverage.join(', ')}', style: const TextStyle(color: Colors.white70))),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Review progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('$p%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        bar(p),
      ]),
    );
  }

  Widget taskCard(StudyTask t, {bool toggle = true}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Panel(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: kTile2, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.layers_outlined, color: kPurple)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.subject, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: kInk, decoration: t.done ? TextDecoration.lineThrough : null)),
                Text(t.topic, style: const TextStyle(color: kMuted)),
              ])),
              GestureDetector(
                onTap: () => setState(() {
                  t.done = !t.done;
                  if (t.done) s.log('Study session completed', '${t.subject} • ${fmtDate(DateTime.now())}', Icons.check);
                }),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: t.done ? kPurple : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC9B8EE), width: 2)),
                  child: t.done ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.access_time, size: 16, color: kMuted),
              const SizedBox(width: 4),
              Text('${fmtDate(t.date) == fmtDate(today) ? '' : '${fmtDate(t.date)} • '}${t.time.format(context)}', style: const TextStyle(color: kMuted)),
              const SizedBox(width: 14),
              const Icon(Icons.notifications_none, size: 16, color: kMuted),
              const SizedBox(width: 4),
              const Text('15 min before', style: TextStyle(color: kMuted)),
            ]),
            if (t.done || t.repeat) Padding(padding: const EdgeInsets.only(top: 10), child: t.done ? understoodPill() : repeatPill()),
          ]),
        ),
      );

  Widget deleteBg() => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.delete, color: Colors.white),
      );

  // ---------- HOME ----------
  Widget homeTab() {
    final up = s.exams.where((e) => !e.date.isBefore(today)).toList()..sort((a, b) => a.date.compareTo(b.date));
    final next = up.isEmpty ? null : up.first;
    final todayTasks = s.tasks.where((t) => sameDay(t.date, today)).toList();
    final done = s.tasks.where((t) => t.done).length;
    final repeat = s.reviewers.where((r) => r.score != null && r.score! < 80).length;
    final hr = DateTime.now().hour;
    final greet = hr < 12 ? 'Good Morning' : hr < 18 ? 'Good Afternoon' : 'Good Evening';
    final subs = {...s.tasks.map((t) => t.subject)}.toList();

    Widget quick(IconData i, String l, VoidCallback f, Color bg) => Expanded(
          child: GestureDetector(
            onTap: f,
            child: Column(children: [
              Container(height: 64, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Center(child: Icon(i, color: kPurple))),
              const SizedBox(height: 6),
              Text(l, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kInk), textAlign: TextAlign.center),
            ]),
          ),
        );

    return ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: [
      Text('$greet, ${s.first}', style: const TextStyle(color: kMuted)),
      const Text('Ready to study today?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kInk)),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: tile(Icons.access_time, next == null ? '—' : '${next.date.difference(today).inDays} days', 'Next exam', kTile1)),
        const SizedBox(width: 10),
        Expanded(child: tile(Icons.check, '$done/${s.tasks.length}', 'Study done', kTile2)),
        const SizedBox(width: 10),
        Expanded(child: tile(Icons.flag_outlined, '$repeat', 'To repeat', kTile2)),
      ]),
      const SizedBox(height: 14),
      if (next == null)
        const Panel(child: Text('No upcoming exams 🎉'))
      else
        examCard(next),
      section('Quick Actions'),
      Row(children: [
        quick(Icons.calendar_today_outlined, 'Add Exam', () => go(AddExamPage(student: s)), kTile1),
        const SizedBox(width: 10),
        quick(Icons.menu_book_outlined, 'Add Study', () => go(AddStudyPage(student: s, date: today)), kTile2),
        const SizedBox(width: 10),
        quick(Icons.layers_outlined, 'Add Reviewer', () => go(AddReviewerPage(student: s)), kTile2),
        const SizedBox(width: 10),
        quick(Icons.auto_awesome_outlined, 'Take a Quiz', quickQuiz, kTile2),
      ]),
      section("Today's Study Plan", action: 'See all', onAction: () => setState(() => tab = 2)),
      if (todayTasks.isEmpty)
        const Panel(child: Text('Nothing scheduled today. Add a study session.'))
      else
        ...todayTasks.map(taskCard),
      section('Study Progress'),
      Panel(
        child: Row(children: [
          SizedBox(
            width: 90, height: 90,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(value: s.tasks.isEmpty ? 0 : done / s.tasks.length, strokeWidth: 10, color: kPurple, backgroundColor: kTile2, strokeCap: StrokeCap.round),
              Text('${s.tasks.isEmpty ? 0 : (done / s.tasks.length * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$done of ${s.tasks.length} study sessions completed', style: const TextStyle(color: kMuted)),
            const SizedBox(height: 6),
            for (final sub in subs) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(sub, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${_subPct(sub)}%', style: const TextStyle(color: kMuted)),
              ]),
              bar(_subPct(sub), color: kPurple, back: kTile2),
              const SizedBox(height: 6),
            ],
          ])),
        ]),
      ),
      section('Recent Activity'),
      ..._activity(3),
    ]);
  }

  int _subPct(String sub) {
    final l = s.tasks.where((t) => t.subject == sub).toList();
    return l.isEmpty ? 0 : (l.where((t) => t.done).length / l.length * 100).round();
  }

  List<Widget> _activity(int n) => s.activity.reversed.take(n).map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Panel(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: kTile2, borderRadius: BorderRadius.circular(16)), child: Icon(a.icon, color: kPurple)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${a.sub} • ${fmtDate(a.time)} • ${TimeOfDay.fromDateTime(a.time).format(context)}', style: const TextStyle(color: kMuted, fontSize: 12)),
            ])),
          ]),
        ),
      )).toList();

  // ---------- EXAMS ----------
  Widget examTab() {
    final sorted = [...s.exams]..sort((a, b) => a.date.compareTo(b.date));
    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 110), children: [
      if (sorted.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No exams yet. Tap "Add Exam".'))),
      for (var i = 0; i < sorted.length; i++)
        Dismissible(
          key: ObjectKey(sorted[i]),
          direction: DismissDirection.endToStart,
          background: deleteBg(),
          onDismissed: (_) => setState(() {
            s.exams.remove(sorted[i]);
            s.log('Exam deleted', sorted[i].subject, Icons.delete_outline);
          }),
          child: Padding(padding: const EdgeInsets.only(bottom: 12), child: examCard(sorted[i], deep: i.isOdd)),
        ),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _num('${s.exams.length}', 'Exams'),
            _num('${s.tasks.length}', 'Study sessions'),
            _num('${s.reviewers.length}', 'Reviewers'),
          ]),
        ]),
      ),
      const SizedBox(height: 10),
      const Center(child: Text('Swipe left to delete', style: TextStyle(color: kMuted))),
    ]);
  }

  Widget _num(String v, String l) => Column(children: [
        Text(v, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        Text(l, style: const TextStyle(color: kMuted)),
      ]);

  // ---------- STUDY ----------
  Widget studyTab() {
    final monday = sel.subtract(Duration(days: sel.weekday - 1));
    final list = s.tasks.where((t) => sameDay(t.date, sel)).toList()
      ..sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));
    final pending = list.where((t) => !t.done).length;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), children: [
      Row(children: [
        circBtn(Icons.chevron_left, () => setState(() => sel = sel.subtract(const Duration(days: 7)))),
        Expanded(child: Center(child: pill('${_fullMonths[sel.month - 1]} ${sel.year}', kTile2, kPurple))),
        circBtn(Icons.chevron_right, () => setState(() => sel = sel.add(const Duration(days: 7)))),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => sel = monday.add(Duration(days: i))),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(gradient: sameDay(monday.add(Duration(days: i)), sel) ? kGrad : null, borderRadius: BorderRadius.circular(22)),
                child: Column(children: [
                  Text(_wd[i], style: TextStyle(color: sameDay(monday.add(Duration(days: i)), sel) ? Colors.white : kMuted)),
                  const SizedBox(height: 6),
                  Text('${monday.add(Duration(days: i)).day}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: sameDay(monday.add(Duration(days: i)), sel) ? Colors.white : kInk)),
                ]),
              ),
            ),
          ),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: tile(Icons.access_time, '$pending', 'Pending', kTile1)),
        const SizedBox(width: 12),
        Expanded(child: tile(Icons.check, '${list.length - pending}', 'Done', kTile2)),
      ]),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(sameDay(sel, today) ? "Today's Schedule" : fmtDate(sel), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          GestureDetector(
            onTap: () => go(AddStudyPage(student: s, date: sel)),
            child: Container(width: 54, height: 44, decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.add, color: Colors.white)),
          ),
        ]),
      ),
      if (list.isEmpty) const Panel(child: Text('No study sessions for this day.')),
      for (final t in list)
        Dismissible(
          key: ObjectKey(t),
          direction: DismissDirection.endToStart,
          background: deleteBg(),
          onDismissed: (_) => setState(() {
            s.tasks.remove(t);
            s.log('Study session deleted', t.subject, Icons.delete_outline);
          }),
          child: taskCard(t),
        ),
      const SizedBox(height: 10),
      gBtn('Auto Schedule with AI', autoSchedule, icon: Icons.auto_awesome),
    ]);
  }

  // Simple rule-based placeholder: plan a session the day before each upcoming exam.
  void autoSchedule() {
    var added = 0;
    for (final e in s.exams.where((e) => !e.date.isBefore(today.add(const Duration(days: 1))))) {
      final d = e.date.subtract(const Duration(days: 1));
      if (s.tasks.any((t) => t.subject == e.subject && sameDay(t.date, d))) continue;
      s.tasks.add(StudyTask(e.subject, e.coverage.isEmpty ? 'Final review' : 'Review ${e.coverage.join(', ')}', d, const TimeOfDay(hour: 19, minute: 0)));
      added++;
    }
    if (added > 0) s.log('Auto scheduled', '$added study session(s)', Icons.auto_awesome);
    setState(() {});
    toast(context, added > 0 ? 'Added $added study session(s).' : 'Your schedule is already up to date.');
  }

  // ---------- REVIEWER ----------
  Widget reviewerTab() {
    final subs = subjectsOf(s).where((x) => s.reviewers.any((r) => r.subject == x)).toList();
    Widget status(Reviewer r) => r.score == null
        ? pill('Not studied yet', const Color(0xFFE5E0EE), kMuted)
        : r.score! < 80 ? repeatPill() : understoodPill();
    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 110), children: [
      for (var i = 0; i < subs.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: i.isEven ? kGrad : kDeep, borderRadius: BorderRadius.circular(28)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(subs[i], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              Text('${s.reviewers.where((r) => r.subject == subs[i]).length} reviewer • ${s.reviewers.firstWhere((r) => r.subject == subs[i]).title}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(i.isEven ? 'Understanding' : 'Confidence', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${subjectProgress(s, subs[i])}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 6),
              bar(subjectProgress(s, subs[i])),
            ]),
          ),
        ),
      section('Topics'),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('How understanding is measured', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          Row(children: [pill('Not studied yet', const Color(0xFFE5E0EE), kMuted), const SizedBox(width: 10), const Text('No quiz taken yet', style: TextStyle(color: kMuted))]),
          const SizedBox(height: 8),
          Row(children: [repeatPill(), const SizedBox(width: 10), const Text('Quiz score below 80%', style: TextStyle(color: kMuted))]),
          const SizedBox(height: 8),
          Row(children: [understoodPill(), const SizedBox(width: 10), const Text('Quiz score 80% or higher', style: TextStyle(color: kMuted))]),
        ]),
      ),
      const SizedBox(height: 12),
      for (final r in s.reviewers)
        Dismissible(
          key: ObjectKey(r),
          direction: DismissDirection.endToStart,
          background: deleteBg(),
          onDismissed: (_) => setState(() {
            s.reviewers.remove(r);
            s.log('Reviewer deleted', r.title, Icons.delete_outline);
          }),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: kTile2, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.layers_outlined, color: kPurple)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.subject, style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600)),
                    Text(r.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ])),
                  status(r),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF3EDFB), borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [const Icon(Icons.insert_drive_file_outlined, color: kPurple), const SizedBox(width: 8), Text('${r.file} • ${r.size}', style: const TextStyle(color: kPurple, fontWeight: FontWeight.w600))]),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Quiz score', style: TextStyle(fontWeight: FontWeight.w800)),
                  Text(r.score == null ? 'No quiz yet' : '${r.score}% • ${r.score! < 80 ? 'Needs review' : 'Understood'}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: r.score == null ? kMuted : r.score! < 80 ? kRed : kGreen)),
                ]),
                const SizedBox(height: 6),
                bar(r.score ?? 0, color: (r.score ?? 0) < 80 ? kRed : kGreen, back: kTile2),
                const SizedBox(height: 8),
                Text('${r.cards.length} flashcards and ${r.cards.length} quiz questions ready (made by AI)', style: const TextStyle(color: kMuted, fontSize: 13)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: gBtn('Flashcards', () => go(FlashcardPage(reviewer: r)), icon: Icons.layers_outlined, h: 52)),
                  const SizedBox(width: 10),
                  Expanded(child: oBtn('Take Quiz', () => takeQuiz(r), icon: Icons.check, h: 52)),
                ]),
              ]),
            ),
          ),
        ),
      if (s.reviewers.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No reviewers yet. Tap "Add Reviewer".'))),
    ]);
  }

  void takeQuiz(Reviewer r) {
    var n = 10;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: kTile2, borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 16),
            const Text('Take Quiz', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            Text('${r.title} • ${r.subject}', style: const TextStyle(color: kMuted)),
            const SizedBox(height: 18),
            const Text('How many questions?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton.filled(style: IconButton.styleFrom(backgroundColor: kTile2, foregroundColor: kPurple), onPressed: () => set(() => n = max(10, n - 1)), icon: const Icon(Icons.remove)),
              const SizedBox(width: 16),
              Container(
                width: 130, padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFF3EDFB), borderRadius: BorderRadius.circular(20), border: Border.all(color: kPurple, width: 2)),
                child: Center(child: Text('$n', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(width: 16),
              IconButton.filled(style: IconButton.styleFrom(backgroundColor: kPurple), onPressed: () => set(() => n = min(50, n + 1)), icon: const Icon(Icons.add)),
            ]),
            Slider(value: n.toDouble(), min: 10, max: 50, divisions: 40, activeColor: kPurple, onChanged: (v) => set(() => n = v.round())),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Min 10', style: TextStyle(color: kMuted)), Text('Max 50', style: TextStyle(color: kMuted))]),
            const SizedBox(height: 6),
            const Center(child: Text('Type or slide to any number from 10 to 50.', style: TextStyle(color: kMuted))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: oBtn('Cancel', () => Navigator.pop(ctx))),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: gBtn('Start Quiz', () {
                  Navigator.pop(ctx);
                  final cards = List.generate(n, (i) => r.cards[i % r.cards.length]);
                  go(QuizPage(student: s, reviewer: r, cards: cards, isFull: true));
                }),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ---------- PROFILE ----------
  Widget profileTab() {
    Widget row(IconData i, String t, {Widget? trailing, VoidCallback? f, Color bg = kTile2}) => InkWell(
          onTap: f,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)), child: Icon(i, color: kPurple)),
              const SizedBox(width: 14),
              Expanded(child: Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
              if (trailing != null) trailing,
            ]),
          ),
        );
    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), children: [
      Panel(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Container(
            width: 100, height: 100, alignment: Alignment.center,
            decoration: const BoxDecoration(gradient: kGrad, shape: BoxShape.circle),
            child: Text(s.initials, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          Text(s.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text('ID: ${s.idNumber} • Member since ${fmtDate(s.joined)}', style: const TextStyle(color: kMuted)),
        ]),
      ),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: tile(Icons.calendar_today_outlined, '${s.exams.length}', 'Exams', kTile1)),
        const SizedBox(width: 10),
        Expanded(child: tile(Icons.menu_book_outlined, '${s.tasks.length}', 'Study sessions', kTile2)),
        const SizedBox(width: 10),
        Expanded(child: tile(Icons.layers_outlined, '${s.reviewers.length}', 'Reviewers', kTile2)),
      ]),
      const SizedBox(height: 14),
      Panel(
        child: Column(children: [
          row(Icons.edit_outlined, 'Edit profile', bg: kTile1, f: editProfile),
          const Divider(height: 1),
          row(Icons.lock_outline, 'Change password', f: changePassword),
          const Divider(height: 1),
          row(Icons.notifications_none, 'Study and exam reminders',
              trailing: Switch(value: s.reminders, activeTrackColor: kPurple, onChanged: (v) => setState(() => s.reminders = v))),
          const Divider(height: 1),
          row(Icons.dark_mode_outlined, 'Dark mode',
              trailing: Switch(value: s.dark, activeTrackColor: kPurple, onChanged: (v) {
                setState(() => s.dark = v);
                toast(context, 'Dark mode is not available yet.');
              })),
        ]),
      ),
      const SizedBox(height: 18),
      oBtn('Logout', logout, icon: Icons.logout, color: kRed),
    ]);
  }

  void editProfile() {
    final f = TextEditingController(text: s.first), l = TextEditingController(text: s.last);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: f, decoration: const InputDecoration(labelText: 'First name')),
          TextField(controller: l, decoration: const InputDecoration(labelText: 'Last name')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (f.text.trim().isEmpty || l.text.trim().isEmpty) return;
              setState(() {
                s.first = f.text.trim();
                s.last = l.text.trim();
                s.log('Profile updated', s.fullName, Icons.edit_outlined);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void changePassword() {
    final o = TextEditingController(), n = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: o, obscureText: true, decoration: const InputDecoration(labelText: 'Current password')),
          TextField(controller: n, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (o.text != s.password) return toast(context, 'Current password is incorrect.', err: true);
              if (n.text.length < 4) return toast(context, 'Password must be at least 4 characters.');
              setState(() {
                s.password = n.text;
                s.log('Password changed', 'Account security', Icons.lock_outline);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ============================ SHARED FORM PIECES ============================
Widget subjectDropdown(BuildContext context, Student s, String? value, ValueChanged<String?> onChanged) {
  final subs = subjectsOf(s);
  if (value != null && !subs.contains(value)) subs.add(value);
  return DropdownButtonFormField<String>(
    value: value,
    decoration: deco('Select subject'),
    items: [
      ...subs.map((e) => DropdownMenuItem(value: e, child: Text(e))),
      const DropdownMenuItem(value: '__new', child: Text('+ New subject', style: TextStyle(color: kPurple, fontWeight: FontWeight.bold))),
    ],
    onChanged: (v) async {
      if (v == '__new') {
        final n = await askText(context, 'New subject');
        if (n != null && n.isNotEmpty) onChanged(n);
      } else {
        onChanged(v);
      }
    },
  );
}

Widget pickBox(String text, IconData icon, VoidCallback f) => GestureDetector(
      onTap: f,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFDCCFF2))),
        child: Row(children: [Expanded(child: Text(text, style: const TextStyle(fontSize: 16))), Icon(icon, color: kMuted)]),
      ),
    );

Widget formScaffold(BuildContext context, String title, String sub, List<Widget> body, String saveLabel, VoidCallback save) =>
    Scaffold(
      body: Bg(
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(children: [
                circBtn(Icons.chevron_left, () => Navigator.pop(context)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kInk)),
                  Text(sub, style: const TextStyle(color: kMuted)),
                ])),
              ]),
            ),
            Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: body)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(children: [
                Expanded(child: oBtn('Cancel', () => Navigator.pop(context))),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: gBtn(saveLabel, save)),
              ]),
            ),
          ]),
        ),
      ),
    );

// ============================ ADD EXAM ============================
class AddExamPage extends StatefulWidget {
  final Student student;
  const AddExamPage({super.key, required this.student});
  @override
  State<AddExamPage> createState() => _AddExamPageState();
}

class _AddExamPageState extends State<AddExamPage> {
  Student get s => widget.student;
  String? subject;
  DateTime date = DateTime.now();
  TimeOfDay time = const TimeOfDay(hour: 9, minute: 0);
  final room = TextEditingController();
  final picked = <String>{};
  final custom = <String>[];
  final rem = <String>{'1 day before', '1 hour before'};

  List<String> get topics => {
        ...s.reviewers.where((r) => subject == null || r.subject == subject).map((r) => r.title),
        ...custom,
      }.toList();

  Widget chip(String t, bool on, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: on ? kTile2 : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: on ? kPurple : const Color(0xFFDCCFF2), width: 1.4)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (on) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.check, size: 16, color: kPurple)),
            Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: on ? kPurple : kMuted)),
          ]),
        ),
      );

  void save() {
    if (subject == null) return toast(context, 'Please choose a subject.');
    if (scheduleHasPassed(date, time, DateTime.now())) return toast(context, 'That date/time has already passed.', err: true);
    s.exams.add(Exam(subject!, room.text.trim().isEmpty ? 'TBA' : room.text.trim(), date, time, picked.toList()));
    s.log('Exam added', subject!, Icons.calendar_today_outlined);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => formScaffold(context, 'Add Exam', 'Set your exam schedule', [
        labeled('Subject', subjectDropdown(context, s, subject, (v) => setState(() => subject = v))),
        Row(children: [
          Expanded(
            child: labeled('Date', pickBox(fmtDate(date), Icons.calendar_today_outlined, () async {
              final p = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now().subtract(const Duration(days: 0)), lastDate: DateTime(2100));
              if (p != null) setState(() => date = p);
            })),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: labeled('Time', pickBox(time.format(context), Icons.access_time, () async {
              final p = await showTimePicker(context: context, initialTime: time);
              if (p != null) setState(() => time = p);
            })),
          ),
        ]),
        labeled('Room or location', TextField(controller: room, decoration: deco('Room 201'))),
        labeled('Exam coverage', Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in topics) chip(t, picked.contains(t), () => setState(() => picked.contains(t) ? picked.remove(t) : picked.add(t))),
          GestureDetector(
            onTap: () async {
              final n = await askText(context, 'Add topic');
              if (n != null && n.isNotEmpty) setState(() { custom.add(n); picked.add(n); });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFB9A2EE), width: 1.4)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, size: 16, color: kPurple), SizedBox(width: 4), Text('Add topic', style: TextStyle(color: kPurple, fontWeight: FontWeight.bold))]),
            ),
          ),
        ])),
        const Text('Pick topics from your Reviewers or add your own.', style: TextStyle(color: kMuted)),
        const SizedBox(height: 14),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.notifications_none, color: kPink), SizedBox(width: 8), Text('Exam reminders', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final r in ['1 week before', '1 day before', '1 hour before']) chip(r, rem.contains(r), () => setState(() => rem.contains(r) ? rem.remove(r) : rem.add(r))),
            ]),
          ]),
        ),
      ], 'Save Exam', save);
}

// ============================ ADD STUDY ============================
class AddStudyPage extends StatefulWidget {
  final Student student;
  final DateTime date;
  const AddStudyPage({super.key, required this.student, required this.date});
  @override
  State<AddStudyPage> createState() => _AddStudyPageState();
}

class _AddStudyPageState extends State<AddStudyPage> {
  Student get s => widget.student;
  String? subject;
  late DateTime date = widget.date;
  TimeOfDay time = const TimeOfDay(hour: 19, minute: 0);
  final topic = TextEditingController();

  void save() {
    if (subject == null) return toast(context, 'Please choose a subject.');
    if (scheduleHasPassed(date, time, DateTime.now())) return toast(context, 'That time has already passed. Pick a later time.', err: true);
    s.tasks.add(StudyTask(subject!, topic.text.trim().isEmpty ? 'General review' : topic.text.trim(), date, time));
    s.log('Study session added', subject!, Icons.menu_book_outlined);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => formScaffold(context, 'Add Study', 'Topic, date, reminder', [
        labeled('Subject', subjectDropdown(context, s, subject, (v) => setState(() => subject = v))),
        labeled('Topic to study', TextField(controller: topic, decoration: deco('e.g. Derivatives practice problems'))),
        Row(children: [
          Expanded(
            child: labeled('Date', pickBox(fmtDate(date), Icons.calendar_today_outlined, () async {
              final n = DateTime.now();
              final p = await showDatePicker(context: context, initialDate: date.isBefore(n) ? n : date, firstDate: DateTime(n.year, n.month, n.day), lastDate: DateTime(2100));
              if (p != null) setState(() => date = p);
            })),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: labeled('Time', pickBox(time.format(context), Icons.access_time, () async {
              final p = await showTimePicker(context: context, initialTime: time);
              if (p != null) setState(() => time = p);
            })),
          ),
        ]),
      ], 'Save Session', save);
}

// ============================ ADD REVIEWER ============================
class AddReviewerPage extends StatefulWidget {
  final Student student;
  const AddReviewerPage({super.key, required this.student});
  @override
  State<AddReviewerPage> createState() => _AddReviewerPageState();
}

class _AddReviewerPageState extends State<AddReviewerPage> {
  Student get s => widget.student;
  String? subject;
  final topic = TextEditingController();
  String? file, size;

  // TODO: replace with file_picker + real AI generation.
  void pickFile() {
    final base = topic.text.trim().isEmpty ? 'reviewer' : topic.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    setState(() {
      file = '$base.pdf';
      size = '1.2 MB';
    });
  }

  void save() {
    final t = topic.text.trim();
    if (subject == null || t.isEmpty) return toast(context, 'Please choose a subject and enter a topic.');
    if (file == null) return toast(context, 'Please upload a reviewer file.');
    s.reviewers.add(Reviewer(subject!, t, file!, size!, genCards(t)));
    s.log('Reviewer added', '$t ($subject)', Icons.layers_outlined);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => formScaffold(context, 'Add Reviewer', 'Upload a file and AI does the rest', [
        labeled('Subject', subjectDropdown(context, s, subject, (v) => setState(() => subject = v))),
        labeled('Topic', TextField(controller: topic, decoration: deco('e.g. Derivative rules'))),
        GestureDetector(
          onTap: pickFile,
          child: Container(
            height: 150,
            decoration: BoxDecoration(color: const Color(0xFFF6F1FD), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFFB9A2EE), width: 1.6)),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.upload, color: kPurple, size: 34),
              SizedBox(height: 6),
              Text('Upload reviewer file', style: TextStyle(color: kPurple, fontWeight: FontWeight.w800, fontSize: 18)),
              Text('PDF, DOCX, or images', style: TextStyle(color: kMuted)),
            ]),
          ),
        ),
        if (file != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Panel(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                const Icon(Icons.insert_drive_file_outlined, color: kPurple),
                const SizedBox(width: 8),
                Expanded(child: Text('$file • $size', style: const TextStyle(color: kPurple, fontWeight: FontWeight.w600))),
                GestureDetector(onTap: () => setState(() => file = null), child: const Icon(Icons.close, color: kMuted)),
              ]),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kTile1, borderRadius: BorderRadius.circular(22)),
          child: const Row(children: [
            Icon(Icons.auto_awesome, color: kPink),
            SizedBox(width: 12),
            Expanded(child: Text('Flashcards and quizzes are made automatically by AI from your uploaded file. Your understanding is scored after you take a quiz.')),
          ]),
        ),
      ], 'Save Reviewer', save);
}

// ============================ FLASHCARDS ============================
class FlashcardPage extends StatefulWidget {
  final Reviewer reviewer;
  const FlashcardPage({super.key, required this.reviewer});
  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  int i = 0;
  bool flipped = false;
  List<QCard> get cards => widget.reviewer.cards;

  @override
  Widget build(BuildContext context) {
    final c = cards[i];
    return Scaffold(
      body: Bg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                circBtn(Icons.close, () => Navigator.pop(context)),
                Expanded(child: Center(child: Text('Card ${i + 1} of ${cards.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)))),
                const SizedBox(width: 44),
              ]),
              const SizedBox(height: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => flipped = !flipped),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(gradient: flipped ? kDeep : kGrad, borderRadius: BorderRadius.circular(32)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(flipped ? 'ANSWER' : 'QUESTION', style: const TextStyle(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(flipped ? c.o[c.a] : c.q, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 24),
                      const Text('Tap to flip', style: TextStyle(color: Colors.white60)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: oBtn('Previous', i == 0 ? () {} : () => setState(() { i--; flipped = false; }))),
                const SizedBox(width: 12),
                Expanded(child: gBtn(i == cards.length - 1 ? 'Done' : 'Next', () {
                  if (i == cards.length - 1) return Navigator.pop(context);
                  setState(() { i++; flipped = false; });
                })),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ============================ QUIZ ============================
class QuizPage extends StatefulWidget {
  final Student student;
  final Reviewer reviewer;
  final List<QCard> cards;
  final bool isFull;
  const QuizPage({super.key, required this.student, required this.reviewer, required this.cards, required this.isFull});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int i = 0, correct = 0, streak = 0, best = 0;
  int? picked;
  final wrong = <QCard>[];
  List<QCard> get cards => widget.cards;

  void pick(int j) {
    if (picked != null) return;
    final c = cards[i];
    setState(() {
      picked = j;
      if (j == c.a) {
        correct++;
        streak++;
        best = max(best, streak);
      } else {
        streak = 0;
        wrong.add(c);
      }
    });
  }

  void next() {
    if (i < cards.length - 1) return setState(() { i++; picked = null; });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultPage(
      student: widget.student, reviewer: widget.reviewer, total: cards.length, correct: correct, best: best, wrong: wrong, isFull: widget.isFull)));
  }

  @override
  Widget build(BuildContext context) {
    final c = cards[i];
    Color border(int j) => picked == null ? const Color(0xFFE2D9F3) : j == c.a ? kGreen : j == picked ? kRed : const Color(0xFFE2D9F3);
    Color fill(int j) => picked == null ? Colors.white : j == c.a ? const Color(0xFFDDF3E4) : j == picked ? const Color(0xFFFBE5E2) : Colors.white;
    return Scaffold(
      body: Bg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                circBtn(Icons.close, () => Navigator.pop(context)),
                Expanded(child: Center(child: Text('Card ${i + 1} of ${cards.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)))),
                pill('$streak', Colors.white, kPink, icon: Icons.local_fire_department_outlined),
              ]),
              const SizedBox(height: 14),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: (i + 1) / cards.length, minHeight: 6, color: kPurple, backgroundColor: kTile2)),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(gradient: kGrad, borderRadius: BorderRadius.circular(32)),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          pill(widget.reviewer.subject, Colors.white24, Colors.white),
                          pill('AI generated', Colors.white24, Colors.white),
                        ]),
                        const SizedBox(height: 18),
                        const Text('QUESTION', style: TextStyle(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(c.q, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    for (var j = 0; j < c.o.length; j++)
                      GestureDetector(
                        onTap: () => pick(j),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: fill(j), borderRadius: BorderRadius.circular(24), border: Border.all(color: border(j), width: 2)),
                          child: Row(children: [
                            Container(
                              width: 44, height: 44, alignment: Alignment.center,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: border(j))),
                              child: Text(String.fromCharCode(65 + j), style: TextStyle(fontWeight: FontWeight.bold, color: picked == null ? kInk : border(j))),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Text(c.o[j], style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: picked == null ? kInk : border(j)))),
                            if (picked != null && j == c.a) const Icon(Icons.check, color: kGreen),
                            if (picked != null && j == picked && j != c.a) const Icon(Icons.close, color: kRed),
                          ]),
                        ),
                      ),
                    if (picked != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: kTile1, borderRadius: BorderRadius.circular(20)),
                        child: Text.rich(TextSpan(children: [
                          TextSpan(text: picked == c.a ? 'Correct! ' : 'Incorrect. ', style: const TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: picked == c.a ? 'Nice work.' : 'The answer is ${String.fromCharCode(65 + c.a)}: ${c.o[c.a]}. This card will come back in your review.'),
                        ])),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              if (picked != null) gBtn(i == cards.length - 1 ? 'Finish' : 'Next card', next, icon: Icons.check) else const SizedBox(height: 54),
            ]),
          ),
        ),
      ),
    );
  }
}

// ============================ RESULT ============================
class ResultPage extends StatefulWidget {
  final Student student;
  final Reviewer reviewer;
  final int total, correct, best;
  final List<QCard> wrong;
  final bool isFull;
  const ResultPage({super.key, required this.student, required this.reviewer, required this.total, required this.correct, required this.best, required this.wrong, required this.isFull});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String feel = 'Somewhat';
  late final List<String> topics = widget.wrong.map((c) => c.topic).toSet().toList();

  @override
  void initState() {
    super.initState();
    final s = widget.student, r = widget.reviewer;
    final pct = (widget.correct / widget.total * 100).round();
    if (widget.isFull) r.score = pct;
    s.log('Quiz completed', '${r.title} • $pct%', Icons.check);
    final n = DateTime.now();
    for (final t in topics) {
      if (s.tasks.any((x) => x.topic == t && !x.done && sameDay(x.date, n))) continue;
      s.tasks.add(StudyTask(r.subject, t, DateTime(n.year, n.month, n.day), TimeOfDay(hour: min(n.hour + 1, 23), minute: 0), repeat: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reviewer;
    Widget stat(String v, String l, Color bg, Color fg) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [Text(v, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: fg)), Text(l, style: TextStyle(color: fg))]),
          ),
        );
    return Scaffold(
      body: Bg(
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Quiz Result', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: kInk)),
                Text('Flashcard session finished', style: TextStyle(color: kMuted)),
              ])),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), children: [
                Panel(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    SizedBox(
                      width: 150, height: 150,
                      child: Stack(alignment: Alignment.center, children: [
                        SizedBox(width: 150, height: 150, child: CircularProgressIndicator(value: widget.correct / widget.total, strokeWidth: 14, color: kPink, backgroundColor: kTile2, strokeCap: StrokeCap.round)),
                        Text('${widget.correct}/${widget.total}', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.correct / widget.total >= .8 ? 'Great job, ${widget.student.first}!' : 'Keep going, ${widget.student.first}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    Text('${r.title} • ${widget.total} cards', style: const TextStyle(color: kMuted)),
                    const SizedBox(height: 14),
                    Row(children: [
                      stat('${widget.correct}', 'Correct', const Color(0xFFDDF3E4), kGreen),
                      const SizedBox(width: 10),
                      stat('${widget.total - widget.correct}', 'Wrong', const Color(0xFFFBE5E2), kRed),
                      const SizedBox(width: 10),
                      stat('${widget.best}', 'Best streak', kTile2, const Color(0xFF5B21B6)),
                    ]),
                  ]),
                ),
                const Padding(padding: EdgeInsets.only(top: 18, bottom: 10), child: Text('Topics to review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                if (topics.isEmpty) const Panel(child: Text('Perfect! Nothing to repeat. 🎉')),
                for (final t in topics)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Panel(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFFBE5E2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.flag_outlined, color: kRed)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                          const Text("Added to Today's Study Plan", style: TextStyle(color: kMuted)),
                        ])),
                        pill('REPEAT', const Color(0xFFFBE5E2), kRed),
                      ]),
                    ),
                  ),
                Panel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('How well do you understand this topic now?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(children: [
                      for (final f in ['Not yet', 'Somewhat', 'Understood'])
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => feel = f),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: feel == f ? kTile2 : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: feel == f ? kPurple : const Color(0xFFDCCFF2), width: 1.4)),
                              child: Center(child: Text(f, style: TextStyle(fontWeight: FontWeight.bold, color: feel == f ? kPurple : kMuted))),
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 8),
                    const Text('A score below 80% flags this topic as REPEAT TOPIC.', style: TextStyle(color: kMuted, fontSize: 13)),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(children: [
                if (widget.wrong.isNotEmpty) ...[
                  gBtn('Retry missed cards', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizPage(student: widget.student, reviewer: r, cards: widget.wrong, isFull: false))), icon: Icons.auto_awesome),
                  const SizedBox(height: 10),
                ],
                oBtn('Back to Reviewer', () => Navigator.popUntil(context, (route) => route.isFirst), icon: Icons.layers_outlined),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}