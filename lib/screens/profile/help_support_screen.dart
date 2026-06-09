import 'dart:ui';

import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {

  const HelpSupportScreen({
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

                    "Help & Support",

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

                                  Icons.support_agent_rounded,

                                  color: Colors.white,

                                  size: 46,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(

                            "Need Help?",

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(

                              color: Colors.white,

                              fontSize: 25,

                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(

                            "We're here to help you with courses, chats, account issues, and app support anytime.",

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
                    // SUPPORT CARDS
                    // =================================================

                    _premiumTile(

                      icon:
                      Icons.help_outline_rounded,

                      title:
                      "FAQs",

                      subtitle:
                      "Find answers to commonly asked questions quickly.",

                      color1:
                      const Color(0xff6C63FF),

                      color2:
                      const Color(0xff9C6BFF),
                    ),

                    _premiumTile(

                      icon:
                      Icons.email_outlined,

                      title:
                      "Contact Support",

                      subtitle:
                      "Reach our support team for direct assistance.",

                      color1:
                      const Color(0xffFF7B54),

                      color2:
                      const Color(0xffFFB26B),
                    ),

                    _premiumTile(

                      icon:
                      Icons.bug_report_outlined,

                      title:
                      "Report Issue",

                      subtitle:
                      "Report bugs or technical problems in the app.",

                      color1:
                      const Color(0xff00B894),

                      color2:
                      const Color(0xff55EFC4),
                    ),

                    _premiumTile(

                      icon:
                      Icons.chat_bubble_outline_rounded,

                      title:
                      "Live Chat Support",

                      subtitle:
                      "Connect instantly with our realtime support team.",

                      color1:
                      const Color(0xff0984E3),

                      color2:
                      const Color(0xff74B9FF),
                    ),

                    const SizedBox(height: 30),

                    // =================================================
                    // INFO CARD
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

                        children: [

                          Container(

                            height: 70,
                            width: 70,

                            decoration: BoxDecoration(

                              gradient:
                              const LinearGradient(

                                colors: [

                                  Color(0xff6C63FF),

                                  Color(0xff9D6BFF),
                                ],
                              ),

                              borderRadius:
                              BorderRadius.circular(24),
                            ),

                            child: const Icon(

                              Icons.headset_mic_rounded,

                              color: Colors.white,

                              size: 34,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(

                            "24/7 Customer Support",

                            style: TextStyle(

                              fontSize: 18,

                              fontWeight:
                              FontWeight.w700,

                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(

                            "Our support team is always available to assist you with app usage, realtime chat, course access, payments, and account support.",

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(

                              fontSize: 13,

                              height: 1.8,

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

    required Color color1,

    required Color color2,
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

            height: 60,
            width: 60,

            decoration: BoxDecoration(

              gradient:
              LinearGradient(

                colors: [

                  color1,

                  color2,
                ],
              ),

              borderRadius:
              BorderRadius.circular(20),
            ),

            child: Icon(

              icon,

              color: Colors.white,

              size: 30,
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

          const Icon(

            Icons.arrow_forward_ios_rounded,

            size: 16,

            color: Colors.black38,
          ),
        ],
      ),
    );
  }
}