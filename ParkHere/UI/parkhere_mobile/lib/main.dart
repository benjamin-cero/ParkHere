import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:parkhere_mobile/layouts/master_screen.dart';
import 'package:parkhere_mobile/providers/auth_provider.dart';
import 'package:parkhere_mobile/providers/city_provider.dart';
import 'package:parkhere_mobile/providers/gender_provider.dart';
import 'package:parkhere_mobile/providers/review_provider.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/providers/vehicle_provider.dart';
import 'package:parkhere_mobile/providers/parking_spot_provider.dart';
import 'package:parkhere_mobile/providers/parking_sector_provider.dart';
import 'package:parkhere_mobile/providers/parking_reservation_provider.dart';
import 'package:parkhere_mobile/providers/parking_session_provider.dart';
import 'package:parkhere_mobile/screens/register_screen.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    stripe.Stripe.publishableKey = dotenv.env["STRIPE_PUBLISHABLE_KEY"] ?? "";
    stripe.Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    stripe.Stripe.urlScheme = 'flutterstripe';
    await stripe.Stripe.instance.applySettings();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<ReviewProvider>(create: (_) => ReviewProvider()),
        ChangeNotifierProvider<CityProvider>(create: (_) => CityProvider()),
        ChangeNotifierProvider<GenderProvider>(create: (_) => GenderProvider()),
        ChangeNotifierProvider<VehicleProvider>(create: (_) => VehicleProvider()),
        ChangeNotifierProvider<ParkingSpotProvider>(create: (_) => ParkingSpotProvider()),
        ChangeNotifierProvider<ParkingSectorProvider>(create: (_) => ParkingSectorProvider()), // Added
        ChangeNotifierProvider<ParkingReservationProvider>(create: (_) => ParkingReservationProvider()), // Added
        ChangeNotifierProvider<ParkingSessionProvider>(create: (_) => ParkingSessionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkHere Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F855A), // Calming green
          primary: const Color(0xFF2F855A),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic)),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: AppGradients.mainBackground),
          child: Stack(
            children: [
              // Floating Decorative Bubbles
              Positioned(
                top: -50,
                left: -50,
                child: _buildBubble(150, Colors.white.withOpacity(0.05)),
              ),
              Positioned(
                bottom: 100,
                right: -30,
                child: _buildBubble(100, Colors.white.withOpacity(0.03)),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Logo
                            _buildLogo(),
                            const SizedBox(height: 24),

                            // App Title
                            const Text(
                              "ParkHere",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              "Your Personal Parking Assistant",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Login Card (Glassmorphic)
                            _buildLoginCard(),
                            const SizedBox(height: 32),

                            // Footer Links
                            _buildFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.asset(
            "assets/images/3.png",
            width: 90,
            height: 90,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 450),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Sign In",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: "Username",
            controller: usernameController,
            prefixIcon: Icons.person_outline_rounded,
            hintText: "Enter your username",
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: "Password",
            controller: passwordController,
            obscureText: !_isPasswordVisible,
            prefixIcon: Icons.lock_outline_rounded,
            hintText: "Enter your password",
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textLight,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            text: "Continue",
            onPressed: _isLoading ? null : _handleLogin,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorDialog("Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final username = usernameController.text;
      final password = passwordController.text;

      AuthProvider.username = username;
      AuthProvider.password = password;

      final userProvider = UserProvider();
      final user = await userProvider.authenticate(username, password);

      if (user != null) {
        bool hasStandardUserRole = user.roles.any((role) => role.id == 2);
        if (hasStandardUserRole) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MasterScreen(
                  child: SizedBox.shrink(),
                  title: 'ParkHere',
                ),
                settings: const RouteSettings(name: 'MasterScreen'),
              ),
            );
          }
        } else {
          if (mounted) _showAccessDeniedDialog();
        }
      } else {
        if (mounted) _showErrorDialog("Invalid username or password.");
      }
    } catch (e) {
      if (mounted) _showErrorDialog("Connection failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                "Oops! Something's wrong",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, height: 1.5),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: "Try Again",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.security_rounded, color: AppColors.primary, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                "Access Limited",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Only standard users can log in to this application. Please contact support if you believe this is an error.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, height: 1.5),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: "Understood",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
