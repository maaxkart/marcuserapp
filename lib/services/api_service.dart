import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
class ApiService {
  static const String baseUrl =
      'https://tictechnologies.in/stage/marcappbackend/tutor-admin/public/api';

  // ===========================
  // 🔐 GET TOKEN
  // ===========================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ===========================
  // 🔐 LOGIN API (FIXED)
  // ===========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      print("LOGIN RESPONSE: $data");

      if (response.statusCode == 200 && data['status'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // 🔥 SAVE TOKEN + USER DATA
        await prefs.setString("token", data["token"] ?? "");
        await prefs.setInt(
          "user_id",
          data["user"]["id"],
        );
        await prefs.setString("name", data["user"]?["name"] ?? "");
        await prefs.setString("email", data["user"]?["email"] ?? "");

        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Login failed",
        };
      }
    } catch (e) {
      print("LOGIN ERROR: $e");

      return {
        "success": false,
        "message": "Something went wrong",
      };
    }
  }

  // ===========================
  // 📂 GET STUDENT CATEGORIES
  // ===========================
  static Future<List<dynamic>> getCategories() async {
    final token = await getToken();

    final url = Uri.parse("$baseUrl/categories");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("CATEGORY RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print("CATEGORY ERROR: $e");
    }

    return [];
  }

  // ===========================
  // 📚 GET COURSES BY CATEGORY
  // ===========================
  static Future<List<dynamic>> getCoursesByCategory(int categoryId) async {
    final token = await getToken();

    final url = Uri.parse("$baseUrl/courses/category/$categoryId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("COURSE RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print("COURSE ERROR: $e");
    }

    return [];
  }

  // ===========================
  // 🚪 LOGOUT (OPTIONAL)
  // ===========================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<List<dynamic>> getLessons(int courseId) async {
    final token = await getToken();

    final url = Uri.parse("$baseUrl/course/$courseId/lessons");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("LESSON STATUS : ${response.statusCode}");
      print("LESSON BODY : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print("LESSON ERROR : $e");
    }

    return [];
  }

  static Future<Map<String, dynamic>>
  getMyCourses() async {

    final token = await getToken();

    final url = Uri.parse("$baseUrl/my-courses");

    try {

      final response = await http.get(

        url,

        headers: {

          "Authorization": "Bearer $token",

          "Accept": "application/json",
        },
      );

      print(
        "MY COURSES RESPONSE : ${response.body}",
      );

      if (response.statusCode == 200) {

        final data =
        jsonDecode(response.body);

        return data;
      }

    } catch (e) {

      print(
        "MY COURSES ERROR : $e",
      );
    }

    return {};
  }

  static Future<void> enrollCourse(int courseId) async {

    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/courses/enroll/$courseId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("ENROLL RESPONSE : ${response.body}");
  }

  static Future<void> completeLesson(
      {

    required int lessonId,
    required int courseId,
  }) async {


    final token = await getToken();

    print("TOKEN : $token");

    final response = await http.post(
      Uri.parse("$baseUrl/lesson/complete"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "lesson_id": lessonId.toString(),
        "course_id": courseId.toString(),
      },
    );

    print("COMPLETE LESSON : ${response.body}");
  }

  static Future<List<dynamic>> getTutors() async {

    final token = await getToken();

    final response = await http.get(

      Uri.parse("$baseUrl/tutors"),

      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    return data['data'] ?? [];
  }
  static Future<Map<String, dynamic>>
  updateProfile({

    required String name,
    required String email,

  }) async {

    final prefs =
    await SharedPreferences.getInstance();

    final token =
    prefs.getString("token");

    final response = await http.post(

      Uri.parse(
        "$baseUrl/update-profile",
      ),

      headers: {

        "Accept": "application/json",

        "Authorization":
        "Bearer $token",
      },

      body: {

        "name": name,

        "email": email,
      },
    );

    return jsonDecode(response.body);
  }
  // =========================================================
  // 🔥 POPULAR COURSES
  // =========================================================

  static Future<List<dynamic>>
  getPopularCourses() async {

    final token =
    await getToken();

    final response = await http.get(

      Uri.parse(
        "$baseUrl/popular-courses",
      ),

      headers: {

        "Authorization":
        "Bearer $token",

        "Accept":
        "application/json",
      },
    );

    print(
      "POPULAR COURSES : ${response.body}",
    );

    if (response.statusCode == 200) {

      final data =
      jsonDecode(response.body);

      return data['data'] ?? [];
    }

    return [];
  }

  // =========================================================
  // 👨‍🏫 TOP TUTORS
  // =========================================================

  static Future<List<dynamic>>
  getTopTutors() async {

    final token =
    await getToken();

    final response = await http.get(

      Uri.parse(
        "$baseUrl/top-tutors",
      ),

      headers: {

        "Authorization":
        "Bearer $token",

        "Accept":
        "application/json",
      },
    );

    print(
      "TOP TUTORS : ${response.body}",
    );

    if (response.statusCode == 200) {

      final data =
      jsonDecode(response.body);

      return data['data'] ?? [];
    }

    return [];
  }

  // =========================================================
  // 🔴 LIVE TUTORS
  // =========================================================

  static Future<List<dynamic>>
  getLiveTutors() async {

    final token =
    await getToken();

    final response = await http.get(

      Uri.parse(
        "$baseUrl/live-tutors",
      ),

      headers: {

        "Authorization":
        "Bearer $token",

        "Accept":
        "application/json",
      },
    );

    print(
      "LIVE TUTORS : ${response.body}",
    );

    if (response.statusCode == 200) {

      final data =
      jsonDecode(response.body);

      return data['data'] ?? [];
    }

    return [];
  }

  // =========================================================
  // 👤 GET PROFILE
  // =========================================================

  static Future<Map<String, dynamic>>
  getProfile() async {

    final token =
    await getToken();

    final response = await http.get(

      Uri.parse(
        "$baseUrl/profile",
      ),

      headers: {

        "Authorization":
        "Bearer $token",

        "Accept":
        "application/json",
      },
    );

    print(
      "PROFILE RESPONSE : ${response.body}",
    );

    if (response.statusCode == 200) {

      final data =
      jsonDecode(response.body);

      return data['data'] ?? {};
    }

    return {};
  }

  static Future<List<dynamic>>
  getCoursesByCategoryhome(
      int categoryId,
      ) async {

    final token =
    await getToken();

    final response =
    await http.get(

      Uri.parse(

        "$baseUrl/courses-by-category/$categoryId",
      ),

      headers: {

        "Authorization":
        "Bearer $token",

        "Accept":
        "application/json",
      },
    );

    print(
      "CATEGORY COURSES : ${response.body}",
    );

    if (response.statusCode == 200) {

      final data =
      jsonDecode(response.body);

      return data['data'] ?? [];
    }

    return [];
  }

  // =====================================================
  // LIVE COURSES
  // =====================================================

  static Future<List<dynamic>>
  getLiveCourses() async {

    final token =
    await getToken();

    final response =
    await http.get(

      Uri.parse(
        "$baseUrl/live-courses",
      ),

      headers: {

        "Authorization":
        "Bearer $token",

        "Accept":
        "application/json",
      },
    );
    if (response.statusCode == 200) {

      print("LIVE COURSES : ${response.body}");

      final data =
      jsonDecode(response.body);

      return data['data'] ?? [];
    }

    return [];
  }
  // =====================================================
  // GET BANNERS
  // =====================================================

  static Future<List<dynamic>>
  getBanners() async {

    try {

      final token =
      await getToken();

      final response =
      await http.get(

        Uri.parse(
          "$baseUrl/banners",
        ),

        headers: {

          "Authorization":
          "Bearer $token",

          "Accept":
          "application/json",
        },
      );

      print(
        "BANNERS : ${response.body}",
      );

      if (response.statusCode == 200) {

        final data =
        jsonDecode(response.body);

        return data['data'] ?? [];
      }

      return [];

    } catch (e) {

      print(e);

      return [];
    }
  }

  static Future<void> updateStreak() async {

    try {

      final token = await getToken();

      final prefs =
      await SharedPreferences.getInstance();

      final userId =
      prefs.getInt("user_id");

      print("USER ID : $userId");

      final response = await http.post(

        Uri.parse('$baseUrl/update-streak'),

        headers: {

          'Authorization': 'Bearer $token',

          'Accept': 'application/json',
        },

        body: {

          'user_id': userId.toString(),
        },
      );

      print(
        'STREAK RESPONSE : ${response.body}',
      );

    } catch (e) {

      print(
        'STREAK ERROR : $e',
      );
    }
  }
}