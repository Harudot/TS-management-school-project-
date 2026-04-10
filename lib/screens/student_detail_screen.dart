import 'package:flutter/material.dart';
import 'package:ts_management/widgets/student_widgets/student_profile_card.dart';
import 'package:ts_management/widgets/student_widgets/student_contact.dart';
import 'package:ts_management/widgets/student_widgets/student_performance.dart';
import 'package:ts_management/widgets/student_widgets/student_courses.dart';
import 'package:ts_management/widgets/common/oxalis_app_bar.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({super.key});

  // TODO: Accept a Student model from backend instead of hardcoded data
  static const _courses = [
    CourseItem(name: 'Data Structures', grade: 'A'),
    CourseItem(name: 'Algorithms', grade: 'A-'),
    CourseItem(name: 'Database Systems', grade: 'B+'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12071F),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            const OxalisAppBar(subtitle: 'Teacher', showBack: true),

            // ── Scrollable Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    // ── Part 1: Profile Card ──
                    const StudentProfileCard(
                      name: 'John Doe',
                      studentId: 'ST2021001',
                      department: 'Computer Science',
                    ),

                    const SizedBox(height: 14),

                    // ── Part 2: Contact Info ──
                    const StudentContact(
                      email: 'john.doe@university.edu',
                      phone: '+976 9999-1234',
                    ),

                    const SizedBox(height: 14),

                    // ── Part 3: Academic Performance ──
                    const StudentPerformance(gpa: '3.85', attendance: '95%'),

                    const SizedBox(height: 14),

                    // ── Part 4: Current Courses ──
                    const StudentCourses(courses: _courses),
                  ],
                ),
              ),
            ),

            // ── Bottom Label ──
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'STUDENT DETAIL',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
