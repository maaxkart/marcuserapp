import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsScreen
    extends StatefulWidget {

  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {

  // =====================================================
  // COLORS
  // =====================================================

  static const Color primary =
  Color(0xFF6C3CE7);

  static const Color pink =
  Color(0xFFD63CF0);

  static const Color emerald =
  Color(0xFF00FFA3);

  static const Color ink =
  Color(0xFF1A1060);

  static const Color muted =
  Color(0xFF9FA3B0);

  static const Color surface =
  Color(0xFFF4F5FF);

  late final AnimationController
  orbController;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {

    super.initState();

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
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: surface,

      body: AnimatedBuilder(

        animation: orbController,

        builder: (_, __) {

          final t =
              orbController.value *
                  2 *
                  math.pi;

          return Stack(

            children: [

              // =========================================
              // ORBS
              // =========================================

              Positioned(

                top: -100,
                right: -80,

                child: _orb(
                  primary.withOpacity(0.08),
                  240,
                ),
              ),

              Positioned(

                bottom: -80,
                left: -70,

                child: _orb(
                  pink.withOpacity(0.06),
                  220,
                ),
              ),

              Positioned(

                top:
                140 +
                    8 *
                        math.sin(t),

                right:
                60 +
                    8 *
                        math.cos(t),

                child: _dot(
                  emerald,
                  8,
                ),
              ),

              // =========================================
              // CONTENT
              // =========================================

              SafeArea(

                child: Column(

                  children: [

                    // =====================================
                    // APP BAR
                    // =====================================

                    Padding(

                      padding:
                      const EdgeInsets.fromLTRB(
                          20,
                          14,
                          20,
                          24),

                      child: Row(

                        children: [

                          GestureDetector(

                            onTap: () {

                              Navigator.pop(
                                  context);
                            },

                            child: Container(

                              width: 46,
                              height: 46,

                              decoration:
                              BoxDecoration(

                                color:
                                Colors.white,

                                borderRadius:
                                BorderRadius.circular(
                                    16),

                                boxShadow: [

                                  BoxShadow(

                                    color:
                                    Colors.black
                                        .withOpacity(
                                        0.04),

                                    blurRadius:
                                    12,

                                    offset:
                                    const Offset(
                                        0,
                                        4),
                                  ),
                                ],
                              ),

                              child: const Icon(

                                Icons
                                    .arrow_back_ios_new_rounded,

                                size: 18,

                                color: ink,
                              ),
                            ),
                          ),

                          const Spacer(),

                          const Text(

                            "Notifications",

                            style: TextStyle(

                              fontSize: 18,

                              fontWeight:
                              FontWeight.w700,

                              color: ink,
                            ),
                          ),

                          const Spacer(),

                          Container(

                            padding:
                            const EdgeInsets.symmetric(

                              horizontal: 12,
                              vertical: 7,
                            ),

                            decoration:
                            BoxDecoration(

                              color:
                              primary.withOpacity(
                                  0.08),

                              borderRadius:
                              BorderRadius.circular(
                                  12),
                            ),

                            child: const Text(

                              "LIVE",

                              style: TextStyle(

                                color: primary,

                                fontSize: 11,

                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =====================================
                    // NOTIFICATIONS LIST
                    // =====================================

                    Expanded(

                      child: StreamBuilder(

                        stream:
                        FirebaseFirestore.instance

                            .collection(
                            'notifications')

                            .orderBy(
                            'timestamp',
                            descending: true)

                            .snapshots(),

                        builder:
                            (context, snapshot) {

                          // LOADING

                          if (
                          snapshot.connectionState ==
                              ConnectionState
                                  .waiting) {

                            return const Center(

                              child:
                              CircularProgressIndicator(),
                            );
                          }

                          // EMPTY

                          if (
                          !snapshot.hasData ||

                              snapshot.data!.docs
                                  .isEmpty) {

                            return _buildEmpty();
                          }

                          final notifications =
                              snapshot.data!.docs;

                          return ListView.builder(

                            padding:
                            const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 30,
                            ),

                            physics:
                            const BouncingScrollPhysics(),

                            itemCount:
                            notifications.length,

                            itemBuilder:
                                (_, index) {

                              final data =
                              notifications[index]
                                  .data();

                              return _buildNotificationCard(

                                title:
                                data['title']
                                    ?? "",

                                subtitle:
                                data['message']
                                    ?? "",

                                type:
                                data['type']
                                    ?? "general",

                                isRead:
                                data['isRead']
                                    ?? false,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

            width: 90,
            height: 90,

            decoration: BoxDecoration(

              color:
              primary.withOpacity(0.08),

              shape: BoxShape.circle,
            ),

            child: const Icon(

              Icons.notifications_none_rounded,

              size: 42,

              color: primary,
            ),
          ),

          const SizedBox(height: 20),

          const Text(

            "No Notifications Yet",

            style: TextStyle(

              fontSize: 18,

              fontWeight:
              FontWeight.w700,

              color: ink,
            ),
          ),

          const SizedBox(height: 8),

          Text(

            "New updates will appear here",

            style: TextStyle(

              fontSize: 13,

              color:
              muted.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // NOTIFICATION CARD
  // =====================================================

  Widget _buildNotificationCard({

    required String title,

    required String subtitle,

    required String type,

    required bool isRead,
  }) {

    IconData icon =
        Icons.notifications_rounded;

    Color iconColor =
        primary;

    if (type == "message") {

      icon =
          Icons.message_rounded;

      iconColor =
          Colors.blue;
    }

    if (type == "course") {

      icon =
          Icons.play_circle_fill_rounded;

      iconColor =
          Colors.orange;
    }

    if (type == "payment") {

      icon =
          Icons.workspace_premium_rounded;

      iconColor =
          Colors.green;
    }

    return Container(

      margin:
      const EdgeInsets.only(bottom: 16),

      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(24),

        border: Border.all(

          color:
          isRead

              ? Colors.transparent

              : primary.withOpacity(0.12),
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

      child: Row(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          // ICON

          Container(

            width: 52,
            height: 52,

            decoration: BoxDecoration(

              color:
              iconColor.withOpacity(0.10),

              borderRadius:
              BorderRadius.circular(18),
            ),

            child: Icon(

              icon,

              color: iconColor,

              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // TEXT

          Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Row(

                  children: [

                    Expanded(

                      child: Text(

                        title,

                        style: const TextStyle(

                          fontSize: 15,

                          fontWeight:
                          FontWeight.w700,

                          color: ink,
                        ),
                      ),
                    ),

                    if (!isRead)

                      Container(

                        width: 9,
                        height: 9,

                        decoration:
                        const BoxDecoration(

                          color: primary,

                          shape:
                          BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(

                  subtitle,

                  style: TextStyle(

                    fontSize: 13,

                    height: 1.45,

                    color:
                    muted.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 12),

                Text(

                  "Just now",

                  style: TextStyle(

                    fontSize: 11,

                    fontWeight:
                    FontWeight.w600,

                    color:
                    muted.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
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

            blurRadius: size * 2,
          ),
        ],
      ),
    );
  }
}