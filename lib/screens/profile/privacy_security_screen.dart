import 'dart:ui';

import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {

  const PrivacySecurityScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xffF5F7FB),

      body: SafeArea(

        child: Column(

          children: [

            // =====================================================
            // TOP BAR
            // =====================================================

            Padding(

              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),

              child: Row(

                children: [

                  GestureDetector(

                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: Container(

                      height: 48,
                      width: 48,

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

                  const Spacer(),

                  const Text(

                    "Privacy Policy",

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight:
                      FontWeight.w700,

                      color: Colors.black87,
                    ),
                  ),

                  const Spacer(),

                  const SizedBox(
                    width: 48,
                  ),
                ],
              ),
            ),

            // =====================================================
            // BODY
            // =====================================================

            Expanded(

              child: SingleChildScrollView(

                physics:
                const BouncingScrollPhysics(),

                padding:
                const EdgeInsets.all(20),

                child: Column(

                  children: [

                    // =================================================
                    // HEADER CARD
                    // =================================================

                    Container(

                      width: double.infinity,

                      padding:
                      const EdgeInsets.all(28),

                      decoration: BoxDecoration(

                        gradient:
                        const LinearGradient(

                          begin:
                          Alignment.topLeft,

                          end:
                          Alignment.bottomRight,

                          colors: [

                            Color(0xff6C63FF),

                            Color(0xff9D6BFF),
                          ],
                        ),

                        borderRadius:
                        BorderRadius.circular(34),

                        boxShadow: [

                          BoxShadow(

                            color:
                            const Color(0xff6C63FF)
                                .withOpacity(.25),

                            blurRadius: 30,

                            offset:
                            const Offset(0, 12),
                          ),
                        ],
                      ),

                      child: Column(

                        children: [

                          ClipRRect(

                            borderRadius:
                            BorderRadius.circular(24),

                            child: BackdropFilter(

                              filter: ImageFilter.blur(
                                sigmaX: 20,
                                sigmaY: 20,
                              ),

                              child: Container(

                                padding:
                                const EdgeInsets.all(22),

                                decoration: BoxDecoration(

                                  color:
                                  Colors.white.withOpacity(.12),

                                  borderRadius:
                                  BorderRadius.circular(24),

                                  border: Border.all(

                                    color:
                                    Colors.white.withOpacity(.2),
                                  ),
                                ),

                                child: const Icon(

                                  Icons.verified_user_rounded,

                                  color: Colors.white,

                                  size: 46,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(

                            "Your Privacy Matters",

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(

                              color: Colors.white,

                              fontSize: 24,

                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(

                            "Marc App securely protects your personal information, learning activities, and realtime communications.",

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(

                              color:
                              Colors.white.withOpacity(.9),

                              fontSize: 13.2,

                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =================================================
                    // FEATURES
                    // =================================================

                    _premiumTile(

                      icon:
                      Icons.lock_outline_rounded,

                      title:
                      "Secure Authentication",

                      subtitle:
                      "Protected login and secure user access.",
                    ),

                    _premiumTile(

                      icon:
                      Icons.cloud_done_rounded,

                      title:
                      "Cloud Protection",

                      subtitle:
                      "Your app data is encrypted using Firebase infrastructure.",
                    ),

                    _premiumTile(

                      icon:
                      Icons.message_rounded,

                      title:
                      "Private Messaging",

                      subtitle:
                      "Realtime chats remain secure and protected.",
                    ),

                    _premiumTile(

                      icon:
                      Icons.notifications_active_rounded,

                      title:
                      "Notification Control",

                      subtitle:
                      "Manage notification permissions anytime.",
                    ),

                    const SizedBox(height: 28),

                    // =================================================
                    // POLICY TEXT
                    // =================================================

                    Container(

                      width: double.infinity,

                      padding:
                      const EdgeInsets.all(24),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(30),

                        boxShadow: [

                          BoxShadow(

                            color:
                            Colors.black.withOpacity(.04),

                            blurRadius: 20,

                            offset:
                            const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          const Text(

                            "Privacy Policy",

                            style: TextStyle(

                              fontSize: 18,

                              fontWeight:
                              FontWeight.w700,

                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(

                            "Marc App collects limited user information required for authentication, realtime messaging, notifications, and personalized learning experiences.\n\n"
                                "We use Firebase secure cloud services to safely store application data. Personal information and user activities are never sold or publicly shared.\n\n"
                                "Your conversations, account details, and educational progress remain protected through modern cloud security technologies.",

                            style: TextStyle(

                              fontSize: 13,

                              height: 1.9,

                              color:
                              Colors.black.withOpacity(.65),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // PREMIUM TILE
  // =====================================================

  Widget _premiumTile({

    required IconData icon,

    required String title,

    required String subtitle,
  }) {

    return Container(

      margin:
      const EdgeInsets.only(bottom: 18),

      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(.04),

            blurRadius: 20,

            offset:
            const Offset(0, 10),
          ),
        ],
      ),

      child: Row(

        children: [

          Container(

            height: 58,
            width: 58,

            decoration: BoxDecoration(

              gradient:
              const LinearGradient(

                colors: [

                  Color(0xff6C63FF),

                  Color(0xff9C6BFF),
                ],
              ),

              borderRadius:
              BorderRadius.circular(18),
            ),

            child: Icon(

              icon,

              color: Colors.white,

              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: const TextStyle(

                    fontSize: 15.5,

                    fontWeight:
                    FontWeight.w700,

                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(

                  subtitle,

                  style: const TextStyle(

                    fontSize: 12.5,

                    height: 1.5,

                    color: Colors.black54,
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