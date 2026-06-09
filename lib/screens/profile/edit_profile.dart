import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {

  final String name;
  final String email;

  const EditProfileScreen({

    super.key,

    required this.name,

    required this.email,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {

  // =====================================================
  // COLORS
  // =====================================================

  static const Color primary =
  Color(0xFF6C63FF);

  static const Color secondary =
  Color(0xFF8B80F8);

  static const Color accent =
  Color(0xFFD96CFF);

  static const Color bg =
  Color(0xFFF5F7FB);

  static const Color textDark =
  Color(0xFF1C1C1E);

  static const Color textGrey =
  Color(0xFF8E8E93);

  late final AnimationController
  orbController;

  final TextEditingController
  nameController =
  TextEditingController();

  final TextEditingController
  emailController =
  TextEditingController();

  bool loading = false;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {

    super.initState();

    nameController.text =
        widget.name;

    emailController.text =
        widget.email;

    orbController =
    AnimationController(

      vsync: this,

      duration:
      const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {

    orbController.dispose();

    super.dispose();
  }

  // =====================================================
  // UPDATE PROFILE
  // =====================================================

  Future<void> updateProfile() async {

    FocusScope.of(context).unfocus();

    setState(() {

      loading = true;
    });

    try {

      final response =
      await ApiService.updateProfile(

        name:
        nameController.text.trim(),

        email:
        emailController.text.trim(),
      );

      setState(() {

        loading = false;
      });

      if (response['success'] == true) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content:
            Text(
              "Profile Updated Successfully",
            ),
          ),
        );

        Navigator.pop(context, true);

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content:
            Text(
              response['message']
                  .toString(),
            ),
          ),
        );
      }

    } catch (e) {

      setState(() {

        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text("Error : $e"),
        ),
      );
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: bg,

      body: AnimatedBuilder(

        animation: orbController,

        builder: (_, __) {

          final t =
              orbController.value *
                  2 *
                  math.pi;

          return Stack(

            children: [

              // =================================================
              // TOP ORB
              // =================================================

              Positioned(

                top: -120,

                right: -80,

                child: _orb(
                  primary.withOpacity(0.10),
                  260,
                ),
              ),

              // =================================================
              // BOTTOM ORB
              // =================================================

              Positioned(

                bottom: -90,

                left: -70,

                child: _orb(
                  accent.withOpacity(0.08),
                  220,
                ),
              ),

              // =================================================
              // FLOATING LIGHT
              // =================================================

              Positioned(

                top: 220,

                left: -40,

                child: Container(

                  width: 140,
                  height: 140,

                  decoration: BoxDecoration(

                    shape: BoxShape.circle,

                    gradient: RadialGradient(

                      colors: [

                        secondary.withOpacity(0.18),

                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // =================================================
              // FLOATING DOTS
              // =================================================

              Positioned(

                top:
                120 +
                    8 *
                        math.sin(t),

                right:
                70 +
                    8 *
                        math.cos(t),

                child: _dot(
                  primary,
                  10,
                ),
              ),

              Positioned(

                top:
                170 +
                    6 *
                        math.cos(t),

                left:
                40 +
                    8 *
                        math.sin(t),

                child: _dot(
                  accent,
                  7,
                ),
              ),

              // =================================================
              // CONTENT
              // =================================================

              SafeArea(

                child: SingleChildScrollView(

                  physics:
                  const BouncingScrollPhysics(),

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      const SizedBox(height: 18),

                      // =============================================
                      // APP BAR
                      // =============================================

                      Row(

                        children: [

                          GestureDetector(

                            onTap: () {

                              Navigator.pop(
                                  context);
                            },

                            child: Container(

                              width: 48,
                              height: 48,

                              decoration:
                              BoxDecoration(

                                color:
                                Colors.white,

                                borderRadius:
                                BorderRadius.circular(
                                    18),

                                boxShadow: [

                                  BoxShadow(

                                    color:
                                    Colors.black
                                        .withOpacity(
                                        0.05),

                                    blurRadius:
                                    12,

                                    offset:
                                    const Offset(
                                        0,
                                        5),
                                  ),
                                ],
                              ),

                              child: const Icon(

                                Icons
                                    .arrow_back_ios_new_rounded,

                                size: 18,

                                color:
                                textDark,
                              ),
                            ),
                          ),

                          const Spacer(),

                          const Text(

                            "Edit Profile",

                            style: TextStyle(

                              fontSize: 19,

                              fontWeight:
                              FontWeight.w700,

                              letterSpacing: -0.3,

                              color:
                              textDark,
                            ),
                          ),

                          const Spacer(),

                          const SizedBox(
                            width: 48,
                          ),
                        ],
                      ),

                      const SizedBox(height: 42),

                      // =============================================
                      // PREMIUM AVATAR
                      // =============================================

                      Center(

                        child: Stack(

                          alignment: Alignment.center,

                          children: [

                            // OUTER GLOW

                            Container(

                              width: 138,
                              height: 138,

                              decoration: BoxDecoration(

                                shape:
                                BoxShape.circle,

                                gradient:
                                RadialGradient(

                                  colors: [

                                    primary.withOpacity(.25),

                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // MAIN AVATAR

                            Container(

                              width: 112,
                              height: 112,

                              padding:
                              const EdgeInsets.all(3),

                              decoration: BoxDecoration(

                                shape:
                                BoxShape.circle,

                                gradient:
                                const LinearGradient(

                                  begin:
                                  Alignment.topLeft,

                                  end:
                                  Alignment.bottomRight,

                                  colors: [

                                    Color(0xff7B61FF),

                                    Color(0xff9F6BFF),

                                    Color(0xff6C63FF),
                                  ],
                                ),

                                boxShadow: [

                                  BoxShadow(

                                    color:
                                    primary.withOpacity(.35),

                                    blurRadius: 28,

                                    spreadRadius: 2,

                                    offset:
                                    const Offset(0, 12),
                                  ),
                                ],
                              ),

                              child: Container(

                                decoration: BoxDecoration(

                                  shape:
                                  BoxShape.circle,

                                  border: Border.all(

                                    color:
                                    Colors.white,

                                    width: 3,
                                  ),

                                  gradient:
                                  const LinearGradient(

                                    begin:
                                    Alignment.topLeft,

                                    end:
                                    Alignment.bottomRight,

                                    colors: [

                                      Color(0xff6C63FF),

                                      Color(0xff8B80F8),
                                    ],
                                  ),
                                ),

                                child: Center(

                                  child: Text(

                                    nameController.text
                                        .trim()
                                        .isNotEmpty

                                        ? nameController.text
                                        .trim()[0]
                                        .toUpperCase()

                                        : "U",

                                    style:
                                    const TextStyle(

                                      color:
                                      Colors.white,

                                      fontSize:
                                      42,

                                      fontWeight:
                                      FontWeight.w800,

                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ONLINE DOT

                            Positioned(

                              top: 10,
                              right: 14,

                              child: Container(

                                width: 18,
                                height: 18,

                                decoration: BoxDecoration(

                                  color:
                                  const Color(0xff00C853),

                                  shape:
                                  BoxShape.circle,

                                  border: Border.all(

                                    color:
                                    Colors.white,

                                    width: 3,
                                  ),

                                  boxShadow: [

                                    BoxShadow(

                                      color:
                                      Colors.green.withOpacity(.5),

                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // MINI BUTTON

                            Positioned(

                              bottom: 4,
                              right: 2,

                              child: ClipRRect(

                                borderRadius:
                                BorderRadius.circular(18),

                                child: BackdropFilter(

                                  filter: ImageFilter.blur(
                                    sigmaX: 15,
                                    sigmaY: 15,
                                  ),


                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =============================================
                      // TITLE
                      // =============================================

                      const Center(

                        child: Text(

                          "Personal Information",

                          style: TextStyle(

                            fontSize: 21,

                            fontWeight:
                            FontWeight.w700,

                            letterSpacing: -0.2,

                            color:
                            textDark,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Center(

                        child: Text(

                          "Update your profile details",

                          textAlign:
                          TextAlign.center,

                          style: TextStyle(

                            fontSize: 13.2,

                            height: 1.4,

                            color:
                            textGrey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 38),

                      // =============================================
                      // NAME FIELD
                      // =============================================

                      _buildField(

                        controller:
                        nameController,

                        icon:
                        Icons.person_rounded,

                        hint:
                        "Full Name",
                      ),

                      const SizedBox(height: 20),

                      // =============================================
                      // EMAIL FIELD
                      // =============================================

                      _buildField(

                        controller:
                        emailController,

                        icon:
                        Icons.email_rounded,

                        hint:
                        "Email Address",

                        keyboard:
                        TextInputType
                            .emailAddress,
                      ),

                      const SizedBox(height: 46),

                      // =============================================
                      // BUTTON
                      // =============================================

                      SizedBox(

                        width:
                        double.infinity,

                        height: 58,

                        child: ElevatedButton(

                          onPressed:

                          loading

                              ? null

                              : updateProfile,

                          style:
                          ElevatedButton.styleFrom(

                            elevation: 0,

                            backgroundColor:
                            primary,

                            shape:
                            RoundedRectangleBorder(

                              borderRadius:
                              BorderRadius.circular(
                                  22),
                            ),
                          ),

                          child:

                          loading

                              ? const SizedBox(

                            width: 24,
                            height: 24,

                            child:
                            CircularProgressIndicator(

                              color:
                              Colors.white,

                              strokeWidth:
                              2.5,
                            ),
                          )

                              : const Row(

                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                            children: [

                              Icon(

                                Icons
                                    .save_rounded,

                                size: 18,

                                color:
                                Colors.white,
                              ),

                              SizedBox(
                                  width:
                                  8),

                              Text(

                                "Save Changes",

                                style:
                                TextStyle(

                                  fontSize:
                                  15,

                                  fontWeight:
                                  FontWeight
                                      .w600,

                                  letterSpacing:
                                  0.2,

                                  color:
                                  Colors
                                      .white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 45),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =====================================================
  // PREMIUM FIELD
  // =====================================================

  Widget _buildField({

    required TextEditingController
    controller,

    required IconData icon,

    required String hint,

    TextInputType keyboard =
        TextInputType.text,
  }) {

    return Container(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 18,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(24),

        border: Border.all(

          color:
          primary.withOpacity(0.05),
        ),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(0.03),

            blurRadius: 16,

            offset:
            const Offset(0, 8),
          ),
        ],
      ),

      child: Theme(

        data: Theme.of(context).copyWith(

          textSelectionTheme:
          const TextSelectionThemeData(

            cursorColor: primary,

            selectionColor:
            Color(0x336C63FF),
          ),
        ),

        child: TextField(

          controller: controller,

          keyboardType: keyboard,

          style: const TextStyle(

            fontSize: 15,

            fontWeight:
            FontWeight.w500,
          ),

          decoration: InputDecoration(

            border:
            InputBorder.none,

            icon: Icon(

              icon,

              size: 20,

              color: primary,
            ),

            hintText: hint,

            hintStyle:
            const TextStyle(

              color: textGrey,
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // ORB
  // =====================================================

  Widget _orb(
      Color color,
      double size,
      ) {

    return Container(

      width: size,
      height: size,

      decoration: BoxDecoration(

        shape: BoxShape.circle,

        gradient: RadialGradient(

          colors: [

            color,

            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DOT
  // =====================================================

  Widget _dot(
      Color color,
      double size,
      ) {

    return Container(

      width: size,
      height: size,

      decoration: BoxDecoration(

        shape: BoxShape.circle,

        color: color,

        boxShadow: [

          BoxShadow(

            color:
            color.withOpacity(0.6),

            blurRadius:
            size * 2,
          ),
        ],
      ),
    );
  }
}