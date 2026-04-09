import 'package:flutter/material.dart';
import 'package:ts_management/widgets/student_widgets/student_profile_card.dart';
import 'package:ts_management/widgets/student_widgets/student_contact.dart';
import 'package:ts_management/widgets/student_widgets/student_performance.dart';
import 'package:ts_management/widgets/student_widgets/student_courses.dart';

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
            _DetailAppBar(),

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

class _DetailAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          // ── Back ──
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // ── Center ──
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Oxalis Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Teacher',
                  style: TextStyle(color: Color(0x73FFFFFF), fontSize: 11),
                ),
              ],
            ),
          ),

          // ── Bell ──
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1E0D3A).withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9B6BFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
