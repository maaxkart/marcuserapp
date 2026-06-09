import 'dart:ui';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_card.dart';

class SearchScreen extends StatefulWidget {

  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {

  final TextEditingController
  searchController =
  TextEditingController();

  List<dynamic> allCourses = [];

  List<dynamic> filteredCourses = [];

  bool isLoading = true;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {

    super.initState();

    loadCourses();
  }

  // =====================================================
  // LOAD COURSES
  // =====================================================

  Future<void> loadCourses() async {

    try {

      final data =
      await ApiService.getPopularCourses();

      setState(() {

        allCourses = data;

        filteredCourses = data;

        isLoading = false;
      });

    } catch (e) {

      debugPrint(e.toString());

      setState(() {

        isLoading = false;
      });
    }
  }

  // =====================================================
  // SEARCH
  // =====================================================

  void searchCourses(String value) {

    final results =
    allCourses.where((course) {

      final title =
      course['title']
          .toString()
          .toLowerCase();

      return title.contains(
        value.toLowerCase(),
      );

    }).toList();

    setState(() {

      filteredCourses = results;
    });
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xffF5F7FB),

      body: SafeArea(

        child: Column(

          children: [

            // =================================================
            // PREMIUM APP BAR
            // =================================================

            Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),

              child: Row(

                children: [

                  GestureDetector(

                    onTap: () {

                      Navigator.pop(context);
                    },

                    child: Container(

                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(18),

                        boxShadow: [

                          BoxShadow(

                            color:
                            Colors.black.withOpacity(.05),

                            blurRadius: 15,

                            offset:
                            const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: const Icon(

                        Icons.arrow_back_ios_new_rounded,

                        size: 18,

                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(

                    child: Text(

                      "Search Courses",

                      style: TextStyle(

                        fontSize: 20,

                        fontWeight:
                        FontWeight.w700,

                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // SEARCH FIELD
            // =================================================

            Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: ClipRRect(

                borderRadius:
                BorderRadius.circular(26),

                child: BackdropFilter(

                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 15,
                  ),

                  child: Container(

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),

                    decoration: BoxDecoration(

                      color:
                      Colors.white.withOpacity(.85),

                      borderRadius:
                      BorderRadius.circular(26),

                      border: Border.all(

                        color:
                        Colors.white,
                      ),

                      boxShadow: [

                        BoxShadow(

                          color:
                          Colors.black.withOpacity(.04),

                          blurRadius: 20,

                          offset:
                          const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: TextField(

                      controller:
                      searchController,

                      onChanged:
                      searchCourses,

                      style: const TextStyle(

                        fontSize: 15,

                        fontWeight:
                        FontWeight.w500,
                      ),

                      decoration:
                      const InputDecoration(

                        border:
                        InputBorder.none,

                        icon: Icon(

                          Icons.search_rounded,

                          color:
                          Color(0xff6C63FF),
                        ),

                        hintText:
                        "Search premium courses...",

                        hintStyle:
                        TextStyle(

                          color:
                          Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =================================================
            // BODY
            // =================================================

            Expanded(

              child:

              isLoading

                  ? const Center(

                child:
                CircularProgressIndicator(),
              )

                  : filteredCourses.isEmpty

                  ? _buildEmpty()

                  : ListView.builder(

                physics:
                const BouncingScrollPhysics(),

                padding:
                const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),

                itemCount:
                filteredCourses.length,

                itemBuilder:
                    (_, index) {

                  final course =
                  filteredCourses[index];

                  return Padding(

                    padding:
                    const EdgeInsets.only(
                        bottom: 18),

                    child: CourseCard(
                      data: course,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // EMPTY
  // =====================================================

  Widget _buildEmpty() {

    return Center(

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Container(

            width: 110,
            height: 110,

            decoration: BoxDecoration(

              gradient:
              LinearGradient(

                colors: [

                  const Color(0xff6C63FF)
                      .withOpacity(.15),

                  const Color(0xff9F6BFF)
                      .withOpacity(.08),
                ],
              ),

              shape: BoxShape.circle,
            ),

            child: const Icon(

              Icons.search_off_rounded,

              size: 52,

              color: Color(0xff6C63FF),
            ),
          ),

          const SizedBox(height: 24),

          const Text(

            "No Courses Found",

            style: TextStyle(

              fontSize: 22,

              fontWeight:
              FontWeight.w700,

              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          Text(

            "Try searching with another keyword",

            style: TextStyle(

              fontSize: 14,

              color:
              Colors.black.withOpacity(.55),
            ),
          ),
        ],
      ),
    );
  }
}