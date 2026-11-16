import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flashcard.dart';

void main() {
  AuthService.init();
  runApp(const MyApp());
}

// ---------------------------------------------------------------------------
// MODELS
// ---------------------------------------------------------------------------
class Exam {
  String subject;
  String room;
  DateTime date;
  TimeOfDay time;

  Exam({
    required this.subject,
    required this.room,
    required this.date,
    required this.time,
  });
}

class StudyTask {
  String subject;
  String topic;
  DateTime date;
  TimeOfDay time;
  bool done;

  StudyTask({
    required this.subject,
    required this.topic,
    required this.date,
    required this.time,
    this.done = false,
  });
}

class Assignment {
  String subject;
  String title;
  DateTime due;
  bool done;

  Assignment({
    required this.subject,
    required this.title,
    required this.due,
    this.done = false,
  });
}

class Reviewer {
  String subject;
  String title;
  String content;
  final DateTime created;

  Reviewer({required this.subject, required this.title, required this.content})
    : created = DateTime.now();
}

class ActivityLog {
  final String text;
  final IconData icon;
  final DateTime time;

  ActivityLog(this.text, this.icon) : time = DateTime.now();
}

class Student {
  final String idNumber;
  String fullName;
  String password;
  final DateTime joined;
  final List<Exam> exams = [];
  final List<StudyTask> tasks = [];
  final List<Reviewer> reviewers = [];
  final List<Assignment> assignments = [];
  final List<ActivityLog> activity = [];

  Student({
    required this.idNumber,
    required this.fullName,
    required this.password,
  }) : joined = DateTime.now();

  void log(String text, IconData icon) {
    activity.add(ActivityLog(text, icon));
  }

  String get firstName => fullName.trim().split(' ').first;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// AUTH (in-memory, students only)
// ---------------------------------------------------------------------------
class AuthService {
  // Student ID: any digits, exactly this many.
  static const int idLength = 10;

  static final Map<String, Student> students = {};

  static bool isValidId(String id) =>
      id.length == idLength && RegExp(r'^\d+$').hasMatch(id);

  // Demo student so you can test right away.
  static void init() {
    final now = DateTime.now();
    final t = DateTime(now.year, now.month, now.day);

    final s = Student(
      idNumber: '1015140001',
      fullName: 'Juan Dela Cruz',
      password: '1234',
    );
    s.exams.addAll([
      Exam(
        subject: 'Mathematics',
        room: 'Room 201',
        date: t.add(const Duration(days: 3)),
        time: const TimeOfDay(hour: 9, minute: 0),
      ),
      Exam(
        subject: 'Programming 2',
        room: 'Computer Lab 1',
        date: t.add(const Duration(days: 6)),
        time: const TimeOfDay(hour: 13, minute: 30),
      ),
    ]);
    s.tasks.addAll([
      StudyTask(
        subject: 'Mathematics',
        topic: 'Derivatives practice problems',
        date: t,
        time: const TimeOfDay(hour: 19, minute: 0),
      ),
      StudyTask(
        subject: 'Programming 2',
        topic: 'Review Flutter widgets',
        date: t,
        time: const TimeOfDay(hour: 20, minute: 30),
        done: true,
      ),
    ]);
    s.reviewers.addAll([
      Reviewer(
        subject: 'Mathematics',
        title: 'Derivative rules',
        content: 'Power rule: d/dx xⁿ = n·xⁿ⁻¹\nProduct rule: (uv)\' = u\'v + uv\'\nChain rule: f(g(x))\' = f\'(g(x))·g\'(x)',
      ),
      Reviewer(
        subject: 'Programming 2',
        title: 'Flutter basics',
        content: 'StatelessWidget = walay state.\nStatefulWidget = naay setState().\nScaffold, AppBar, ListView, Column, Row ang common widgets.',
      ),
    ]);
    s.assignments.add(
      Assignment(
        subject: 'Programming 2',
        title: 'Flutter app project',
        due: t.add(const Duration(days: 4)),
      ),
    );
    s.log('Account created', Icons.person_add_alt_1);
    students[s.idNumber] = s;
  }
}

// ---------------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------------
const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool scheduleHasPassed(DateTime date, TimeOfDay time, DateTime now) {
  final scheduledAt = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  return scheduledAt.isBefore(now);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExamEase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// LOGIN PAGE
// ---------------------------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idNumberController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;

  void showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  void login() {
    final idNumber = idNumberController.text.trim();
    final password = passwordController.text;

    if (idNumber.isEmpty || password.isEmpty) {
      showMsg('Please enter your ID number and password.');
      return;
    }

    if (!AuthService.isValidId(idNumber)) {
      showMsg(
        'Invalid ID number. It must be exactly ${AuthService.idLength} digits.',
        error: true,
      );
      return;
    }

    final student = AuthService.students[idNumber];
    if (student == null || student.password != password) {
      showMsg('Incorrect ID number or password.', error: true);
      return;
    }

    student.log('Logged in', Icons.login);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage(student: student)),
    );
  }

  @override
  void dispose() {
    idNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.10),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 45,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ExamEase',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Student login',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
                const SizedBox(height: 30),

                // ID NUMBER FIELD
                TextField(
                  controller: idNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(AuthService.idLength),
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'ID Number',
                    hintText: 'Enter your ${AuthService.idLength}-digit ID',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // PASSWORD FIELD
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  onSubmitted: (_) => login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Demo student',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 5),
                const Text(
                  'ID: 1015140001  |  Password: 1234',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create an account',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REGISTER PAGE
// ---------------------------------------------------------------------------
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final idNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;

  void showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  void register() {
    final name = nameController.text.trim();
    final idNumber = idNumberController.text.trim();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (name.isEmpty ||
        idNumber.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      showMsg('Please complete all fields.');
      return;
    }

    if (!AuthService.isValidId(idNumber)) {
      showMsg(
        'Invalid ID number. It must be exactly ${AuthService.idLength} digits.',
        error: true,
      );
      return;
    }

    if (AuthService.students.containsKey(idNumber)) {
      showMsg('This ID number is already registered.', error: true);
      return;
    }

    if (password.length < 4) {
      showMsg('Password must be at least 4 characters.');
      return;
    }

    if (password != confirm) {
      showMsg('Passwords do not match.');
      return;
    }

    final student = Student(
      idNumber: idNumber,
      fullName: name,
      password: password,
    );
    student.log('Account created', Icons.person_add_alt_1);
    AuthService.students[idNumber] = student;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created! You can now log in.')),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    idNumberController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 70,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Student Registration',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: idNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(AuthService.idLength),
                  ],
                  decoration: InputDecoration(
                    labelText: 'ID Number',
                    helperText: 'Any ${AuthService.idLength} digits',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  obscureText: hideConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => hideConfirm = !hideConfirm),
                      icon: Icon(
                        hideConfirm ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: register,
                    child: const Text('REGISTER'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DASHBOARD PAGE (EXAMEASE)
// ---------------------------------------------------------------------------
class DashboardPage extends StatefulWidget {
  final Student student;

  const DashboardPage({super.key, required this.student});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int index = 0;

  Student get student => widget.student;
  List<Exam> get exams => student.exams;
  List<StudyTask> get tasks => student.tasks;
  List<Reviewer> get reviewers => student.reviewers;

  // Tanang subjects gikan sa exams, study tasks, reviewers, ug assignments
  List<String> get allSubjects {
    final set = <String>{
      ...exams.map((e) => e.subject),
      ...tasks.map((t) => t.subject),
      ...reviewers.map((r) => r.subject),
      ...student.assignments.map((a) => a.subject),
    };
    return set.toList()..sort();
  }

  DateTime get today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void logout() {
    student.log('Logged out', Icons.logout);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // ADD EXAM / STUDY SCHEDULE
  Future<void> openAdd({required bool isExam}) async {
    final subject = TextEditingController();
    final extra = TextEditingController();
    DateTime date = today;
    TimeOfDay time = const TimeOfDay(hour: 9, minute: 0);
    String? error;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isExam ? 'Add Exam' : 'Add Study Session',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: subject,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: const Icon(Icons.menu_book_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: extra,
                      decoration: InputDecoration(
                        labelText: isExam ? 'Room / Venue' : 'Topic to study',
                        prefixIcon: Icon(
                          isExam
                              ? Icons.meeting_room_outlined
                              : Icons.edit_note,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(fmtDate(date)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: date,
                                firstDate: today,
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setSheet(() {
                                  date = picked;
                                  error = null;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(time.format(ctx)),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: time,
                              );
                              if (picked != null) {
                                setSheet(() {
                                  time = picked;
                                  error = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
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
                        onPressed: () {
                          final subj = subject.text.trim();
                          if (subj.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a subject.'),
                              ),
                            );
                            return;
                          }

                          final now = DateTime.now();
                          final selectedDay = DateTime(
                            date.year,
                            date.month,
                            date.day,
                          );
                          final currentDay = DateTime(
                            now.year,
                            now.month,
                            now.day,
                          );
                          if (selectedDay.isBefore(currentDay)) {
                            setSheet(
                              () => error = 'That date has already passed. Please pick today or a future date.',
                            );
                            return;
                          }
                          if (scheduleHasPassed(date, time, now)) {
                            setSheet(
                              () => error = 'That time has already passed today. Please pick a later time.',
                            );
                            return;
                          }

                          setState(() {
                            if (isExam) {
                              exams.add(
                                Exam(
                                  subject: subj,
                                  room: extra.text.trim().isEmpty
                                      ? 'TBA'
                                      : extra.text.trim(),
                                  date: date,
                                  time: time,
                                ),
                              );
                              student.log(
                                'Added exam: $subj',
                                Icons.event_note,
                              );
                            } else {
                              tasks.add(
                                StudyTask(
                                  subject: subj,
                                  topic: extra.text.trim().isEmpty
                                      ? 'General review'
                                      : extra.text.trim(),
                                  date: date,
                                  time: time,
                                ),
                              );
                              student.log(
                                'Added study session: $subj',
                                Icons.auto_stories,
                              );
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'SAVE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ADD REVIEWER
  Future<void> openAddReviewer() async {
    final subject = TextEditingController();
    final title = TextEditingController();
    final content = TextEditingController();
    final subjects = allSubjects;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Reviewer',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: subject,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: const Icon(Icons.menu_book_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                if (subjects.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: subjects
                        .map(
                          (s) => ActionChip(
                            label: Text(s),
                            onPressed: () => subject.text = s,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 14),
                TextField(
                  controller: title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Title / Topic',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: content,
                  minLines: 5,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: 'Reviewer notes',
                    helperText:
                        'For flashcards, write one per line: term : meaning',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
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
                    onPressed: () {
                      final subj = subject.text.trim();
                      final ttl = title.text.trim();
                      final body = content.text.trim();
                      if (subj.isEmpty || ttl.isEmpty || body.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please complete all fields.'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        reviewers.add(
                          Reviewer(subject: subj, title: ttl, content: body),
                        );
                        student.log(
                          'Added reviewer: $ttl ($subj)',
                          Icons.note_add,
                        );
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'SAVE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ADD ASSIGNMENT DEADLINE
  Future<void> openAddAssignment() async {
    final subject = TextEditingController();
    final title = TextEditingController();
    DateTime due = today;
    final subjects = allSubjects;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Assignment Deadline',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: subject,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: const Icon(Icons.menu_book_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    if (subjects.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: subjects
                            .map(
                              (s) => ActionChip(
                                label: Text(s),
                                onPressed: () => subject.text = s,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextField(
                      controller: title,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Assignment',
                        prefixIcon: const Icon(Icons.assignment_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text('Due: ${fmtDate(due)}'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: due,
                            firstDate: today,
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setSheet(() => due = picked);
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
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
                        onPressed: () {
                          final subj = subject.text.trim();
                          final ttl = title.text.trim();
                          if (subj.isEmpty || ttl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please complete all fields.'),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            student.assignments.add(
                              Assignment(subject: subj, title: ttl, due: due),
                            );
                            student.log(
                              'Added assignment: $ttl ($subj)',
                              Icons.assignment,
                            );
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'SAVE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void viewReviewer(Reviewer r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(r.title),
        content: SingleChildScrollView(child: Text(r.content)),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              showStudyOptions(
                context,
                '${r.subject} • ${r.title}',
                parseFlashcards(r.content),
                (message) => setState(() {
                  student.log(message, Icons.style);
                }),
              );
            },
            icon: const Icon(Icons.style),
            label: const Text('STUDY'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      homeTab(),
      examTab(),
      studyTab(),
      reviewerTab(),
      profileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1FF),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school_rounded),
            SizedBox(width: 8),
            Text('ExamEase', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: pages[index],
      floatingActionButton: (index >= 1 && index <= 3)
          ? FloatingActionButton.extended(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              onPressed: () {
                if (index == 3) {
                  openAddReviewer();
                } else {
                  openAdd(isExam: index == 1);
                }
              },
              icon: const Icon(Icons.add),
              label: Text(
                index == 1
                    ? 'Add Exam'
                    : index == 2
                    ? 'Add Study'
                    : 'Add Reviewer',
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Exams',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Study',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Reviewer',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // HOME TAB
  Widget homeTab() {
    final upcoming = exams.where((e) => !e.date.isBefore(today)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final next = upcoming.isEmpty ? null : upcoming.first;
    final todayTasks = tasks.where((t) => sameDay(t.date, today)).toList();
    final doneCount = tasks.where((t) => t.done).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Hi, ${student.firstName}! 👋',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Stay on track with your exams.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 18),

        // NEXT EXAM CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: next == null
              ? const Text(
                  'No upcoming exams 🎉',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NEXT EXAM',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            next.subject,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${fmtDate(next.date)} • ${next.time.format(context)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            next.room,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${next.date.difference(today).inDays}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'days left',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16),

        // STATS
        Row(
          children: [
            Expanded(
              child: statCard(
                Icons.event_available,
                '${upcoming.length}',
                'Upcoming exams',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: statCard(
                Icons.task_alt,
                '$doneCount/${tasks.length}',
                'Study done',
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // MINI CALENDAR
        MiniCalendar(
          student: student,
          onAddAssignment: openAddAssignment,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 22),

        // TODAY'S STUDY
        const Text(
          "Today's Study Plan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (todayTasks.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.free_breakfast, color: Colors.brown),
              title: Text('Nothing scheduled today'),
              subtitle: Text('Add a study session in the Study tab.'),
            ),
          )
        else
          ...todayTasks.map(studyCard),
      ],
    );
  }

  Widget statCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // EXAM SCHEDULE TAB
  Widget examTab() {
    final sorted = [...exams]..sort((a, b) => a.date.compareTo(b.date));

    if (sorted.isEmpty) {
      return const Center(child: Text('No exams yet. Tap "Add Exam".'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        const Text(
          'Exam Schedule',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...sorted.map((e) {
          final days = e.date.difference(today).inDays;
          final passed = days < 0;
          return Dismissible(
            key: ObjectKey(e),
            direction: DismissDirection.endToStart,
            background: deleteBackground(),
            onDismissed: (_) => setState(() {
              exams.remove(e);
              student.log('Deleted exam: ${e.subject}', Icons.delete_outline);
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _months[e.date.month - 1].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${e.date.day}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.subject,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${e.time.format(context)} • ${e.room}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      passed
                          ? 'Done'
                          : days == 0
                          ? 'Today'
                          : '${days}d',
                    ),
                    backgroundColor: passed
                        ? Colors.grey.shade200
                        : days <= 3
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                  ),
                ],
              ),
            ),
          );
        }),
        Center(
          child: Text(
            'Swipe left to delete',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget deleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(right: 20),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  // STUDY SCHEDULE TAB
  Widget studyTab() {
    final sorted = [...tasks]
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        if (c != 0) return c;
        return (a.time.hour * 60 + a.time.minute).compareTo(
          b.time.hour * 60 + b.time.minute,
        );
      });

    if (sorted.isEmpty) {
      return const Center(child: Text('No study sessions. Tap "Add Study".'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        const Text(
          'Study Schedule',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...sorted.map(
          (t) => Dismissible(
            key: ObjectKey(t),
            direction: DismissDirection.endToStart,
            background: deleteBackground(),
            onDismissed: (_) => setState(() {
              tasks.remove(t);
              student.log(
                'Deleted study session: ${t.subject}',
                Icons.delete_outline,
              );
            }),
            child: studyCard(t, showDate: true),
          ),
        ),
      ],
    );
  }

  Widget studyCard(StudyTask t, {bool showDate = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: CheckboxListTile(
          value: t.done,
          activeColor: Colors.deepPurple,
          onChanged: (v) => setState(() {
            t.done = v ?? false;
            if (t.done) {
              student.log(
                'Completed study: ${t.subject} (${t.topic})',
                Icons.check_circle_outline,
              );
            }
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            t.subject,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: t.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '${t.topic}\n${showDate ? '${fmtDate(t.date)} • ' : ''}${t.time.format(context)}',
          ),
          isThreeLine: true,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }

  // REVIEWER TAB (grouped by subject)
  Widget reviewerTab() {
    final grouped = <String, List<Reviewer>>{};
    for (final r in reviewers) {
      grouped.putIfAbsent(r.subject, () => []).add(r);
    }
    final subjects = grouped.keys.toList()..sort();

    if (subjects.isEmpty) {
      return const Center(child: Text('No reviewers yet. Tap "Add Reviewer".'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        const Text(
          'Reviewers',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...subjects.map((s) {
          final list = grouped[s]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child:
                        const Icon(Icons.menu_book, color: Colors.deepPurple),
                  ),
                  title: Text(
                    s,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${list.length} reviewer${list.length == 1 ? '' : 's'}',
                  ),
                  children: list
                      .map(
                        (r) => Dismissible(
                          key: ObjectKey(r),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red.shade400,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => setState(() {
                            reviewers.remove(r);
                            student.log(
                              'Deleted reviewer: ${r.title}',
                              Icons.delete_outline,
                            );
                          }),
                          child: ListTile(
                            title: Text(
                              r.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              r.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => viewReviewer(r),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        }),
        Center(
          child: Text(
            'Swipe left to delete',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // PROFILE TAB
  Widget profileTab() {
    final doneCount = tasks.where((t) => t.done).length;
    final progress = tasks.isEmpty ? 0.0 : doneCount / tasks.length;
    final recent = student.activity.reversed.take(20).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // PROFILE HEADER
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(
                  student.initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                student.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${student.idNumber}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                'Member since ${fmtDate(student.joined)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // STATS
        Row(
          children: [
            Expanded(
              child: statCard(
                Icons.event_note,
                '${exams.length}',
                'Exams',
                Colors.deepPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: statCard(
                Icons.auto_stories,
                '${tasks.length}',
                'Study sessions',
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        statCard(
          Icons.menu_book,
          '${reviewers.length}',
          'Reviewers',
          Colors.teal,
        ),
        const SizedBox(height: 12),

        // PROGRESS
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Study Progress',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${(progress * 100).round()}%'),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  color: Colors.deepPurple,
                  backgroundColor: Colors.deepPurple.shade50,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$doneCount of ${tasks.length} study sessions completed',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // ACTIVITY
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          const Card(child: ListTile(title: Text('No activity yet.')))
        else
          ...recent.map(
            (a) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade50,
                  child: Icon(a.icon, color: Colors.deepPurple, size: 20),
                ),
                title: Text(a.text),
                subtitle: Text(
                  '${fmtDate(a.time)} • ${TimeOfDay.fromDateTime(a.time).format(context)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT'),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// MINI CALENDAR
// ---------------------------------------------------------------------------
const List<String> _fullMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class MiniCalendar extends StatefulWidget {
  final Student student;
  final VoidCallback onAddAssignment;
  final VoidCallback onChanged;

  const MiniCalendar({
    super.key,
    required this.student,
    required this.onAddAssignment,
    required this.onChanged,
  });

  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  static const examColor = Colors.deepPurple;
  static const studyColor = Colors.blue;
  static const deadlineColor = Colors.orange;

  late DateTime month;
  late DateTime selected;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    month = DateTime(n.year, n.month);
    selected = DateTime(n.year, n.month, n.day);
  }

  Student get s => widget.student;

  bool hasExam(DateTime d) => s.exams.any((e) => sameDay(e.date, d));
  bool hasStudy(DateTime d) => s.tasks.any((t) => sameDay(t.date, d));
  bool hasDeadline(DateTime d) => s.assignments.any((a) => sameDay(a.due, d));

  void changeMonth(int delta) {
    setState(() => month = DateTime(month.year, month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = DateTime(month.year, month.month, 1).weekday % 7; // Sun=0

    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => changeMonth(-1),
              ),
              Expanded(
                child: Text(
                  '${_fullMonths[month.month - 1]} ${month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => changeMonth(1),
              ),
            ],
          ),

          // WEEKDAY LABELS
          Row(
            children: weekdays
                .map(
                  (w) => Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),

          // DAYS GRID
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: [
              for (int i = 0; i < leading; i++) const SizedBox.shrink(),
              for (int day = 1; day <= daysInMonth; day++)
                _dayCell(DateTime(month.year, month.month, day), today),
            ],
          ),
          const SizedBox(height: 8),

          // LEGEND
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _legend(examColor, 'Exam'),
              _legend(studyColor, 'Study'),
              _legend(deadlineColor, 'Deadline'),
            ],
          ),
          const Divider(height: 24),

          // SELECTED DAY
          Row(
            children: [
              Expanded(
                child: Text(
                  fmtDate(selected),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                onPressed: widget.onAddAssignment,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Deadline'),
              ),
            ],
          ),
          ..._eventsFor(selected),
        ],
      ),
    );
  }

  Widget _dayCell(DateTime d, DateTime today) {
    final isSelected = sameDay(d, selected);
    final isToday = sameDay(d, today);

    return GestureDetector(
      onTap: () => setState(() => selected = d),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : null,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: Colors.deepPurple, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${d.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasExam(d)) _dot(examColor, isSelected),
                if (hasStudy(d)) _dot(studyColor, isSelected),
                if (hasDeadline(d)) _dot(deadlineColor, isSelected),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c, bool onSelected) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: onSelected ? Colors.white : c,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _legend(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  List<Widget> _eventsFor(DateTime d) {
    final exams = s.exams.where((e) => sameDay(e.date, d)).toList();
    final tasks = s.tasks.where((t) => sameDay(t.date, d)).toList();
    final assignments = s.assignments.where((a) => sameDay(a.due, d)).toList();

    if (exams.isEmpty && tasks.isEmpty && assignments.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            'Walay schedule niini nga adlaw.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ),
      ];
    }

    return [
      ...exams.map(
        (e) => _eventTile(
          color: examColor,
          icon: Icons.event_note,
          title: 'Exam: ${e.subject}',
          subtitle: '${e.time.format(context)} • ${e.room}',
        ),
      ),
      ...tasks.map(
        (t) => _eventTile(
          color: studyColor,
          icon: Icons.auto_stories,
          title: 'Study: ${t.subject}',
          subtitle: '${t.topic} • ${t.time.format(context)}',
        ),
      ),
      ...assignments.map(
        (a) => _eventTile(
          color: deadlineColor,
          icon: Icons.assignment,
          title: a.title,
          subtitle: 'Deadline • ${a.subject}',
          strike: a.done,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: a.done,
                activeColor: Colors.deepPurple,
                onChanged: (v) {
                  setState(() => a.done = v ?? false);
                  if (a.done) {
                    s.log('Completed assignment: ${a.title}', Icons.task_alt);
                  }
                  widget.onChanged();
                },
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () {
                  setState(() => s.assignments.remove(a));
                  s.log('Deleted assignment: ${a.title}', Icons.delete_outline);
                  widget.onChanged();
                },
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _eventTile({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    bool strike = false,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: strike ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}