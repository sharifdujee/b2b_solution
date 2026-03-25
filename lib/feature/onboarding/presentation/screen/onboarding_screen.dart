import 'package:b2b_solution/core/design_system/app_color.dart';
import 'package:b2b_solution/core/gloabal/custom_text.dart'; // Keeping your custom widget
import 'package:b2b_solution/core/utils/local_assets/image_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            // Adjust height to control how far down the doodles go
            height: MediaQuery.of(context).size.height * 0.7,
            child: Image.asset(
              ImagePath.onboardTopBG,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),

          Column(
            children: [
              SizedBox(height: 80.h),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                  child: Image.asset(
                    ImagePath.onboardTopFG,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Expanded(
                flex: 5,
                child: ClipPath(
                  clipper: _WaveClipper(),
                  child: Container(
                    width: double.infinity,
                    color: AppColor.primary,
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h),
                        CustomText(
                            text:"CONNECT. TRADE. GROW",
                          textAlign: TextAlign.center,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        SizedBox(height: 16.h),
                        CustomText(
                          text: "Connecting Businesses. Creating Opportunities",
                          textAlign: TextAlign.center,
                          fontSize: 16.sp,
                          color: AppColor.grey600,
                        ),
                        SizedBox(height: 52.h),

                        // 4. Styled Get Started Button
                        SwipeButton(
                          onSwipeComplete: () {
                            context.push('/locationAccessScreen');
                          },
                        ),
                        //SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for the wavy top edge
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // We make these responsive using ScreenUtil
    double cornerCurveHeight = 25.h; // How much the top corners curve out
    double mainDipDepth = 35.h;     // How deep the middle dip goes

    // Define some key X-axis points for smooth transitions
    double startDipX = size.width * 0.1; // 10% in from the left
    double endDipX = size.width * 0.9;   // 10% in from the right

    // 1. Move to the starting point of the top edge (slightly down)
    path.moveTo(0, cornerCurveHeight);

    // 2. LEFT CORNER: Curve from left edge up to top edge
    // Control point is at the intersection (0,0), end point is at top edge.
    path.quadraticBezierTo(
      0, 0, // Control Point
      startDipX, 0, // End Point
    );

    // 3. MAIN DIP: Create the deep curve across the middle
    // Control point is center-horizontally and lower to pull the dip.
    path.quadraticBezierTo(
      size.width / 2, // Control X (centered)
      mainDipDepth * 2, // Control Y (pulled down deep)
      endDipX, 0, // End Point (top edge)
    );

    // 4. RIGHT CORNER: Curve from top edge down to right edge
    // Control point is at (width, 0), end point is down on right edge.
    path.quadraticBezierTo(
      size.width, 0, // Control Point
      size.width, cornerCurveHeight, // End Point
    );

    // 5. Complete the rectangle down the right, left, and close
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SwipeButton extends StatefulWidget {
  final VoidCallback onSwipeComplete;
  const SwipeButton({super.key, required this.onSwipeComplete});

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      double buttonSize = 54.0;
      double maxDrag = maxWidth - buttonSize - 10; // 10 for padding

      return Container(
        height: 70.h,
        padding: EdgeInsets.symmetric(vertical: 3.w),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.secondary,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Stack(
          children: [
            Center(
              child: CustomText(
                text: "Get Started",
                textAlign: TextAlign.center,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              )
            ),
            Positioned(
              left: 5 + _dragValue,

              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragValue = (_dragValue + details.delta.dx).clamp(0.0, maxDrag);
                  });
                },
                onHorizontalDragEnd: (details) {
                  if (_dragValue >= maxDrag * 0.8) {
                    setState(() => _dragValue = maxDrag);
                    widget.onSwipeComplete();
                  } else {
                    setState(() => _dragValue = 0.0);
                  }
                },
                child: Container(
                  height: buttonSize,
                  width: buttonSize,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}