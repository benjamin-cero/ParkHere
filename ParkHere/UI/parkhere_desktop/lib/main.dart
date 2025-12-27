import 'package:flutter/material.dart';
import 'package:parkhere_desktop/providers/auth_provider.dart';
import 'package:parkhere_desktop/providers/city_provider.dart';
import 'package:parkhere_desktop/providers/country_provider.dart';
import 'package:parkhere_desktop/providers/category_provider.dart';
import 'package:parkhere_desktop/providers/subcategory_provider.dart';
import 'package:parkhere_desktop/providers/user_provider.dart';
import 'package:parkhere_desktop/providers/organizer_provider.dart';
import 'package:parkhere_desktop/providers/ticket_type_provider.dart';
import 'package:parkhere_desktop/providers/gender_provider.dart';
import 'package:parkhere_desktop/providers/festival_provider.dart';
import 'package:parkhere_desktop/providers/asset_provider.dart';
import 'package:parkhere_desktop/providers/review_provider.dart';
import 'package:parkhere_desktop/providers/ticket_provider.dart';
import 'package:parkhere_desktop/providers/subcategory_provider.dart';
import 'package:parkhere_desktop/providers/business_report_provider.dart';
import 'package:parkhere_desktop/screens/business_report_screen.dart';
import 'package:parkhere_desktop/screens/city_list_screen.dart';
import 'package:parkhere_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CityProvider>(
          create: (context) => CityProvider(),
        ),
        ChangeNotifierProvider<CountryProvider>(
          create: (context) => CountryProvider(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(),
        ),
        ChangeNotifierProvider<SubcategoryProvider>(
          create: (context) => SubcategoryProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<OrganizerProvider>(
          create: (context) => OrganizerProvider(),
        ),
        ChangeNotifierProvider<TicketTypeProvider>(
          create: (context) => TicketTypeProvider(),
        ),
        ChangeNotifierProvider<GenderProvider>(
          create: (context) => GenderProvider(),
        ),
        ChangeNotifierProvider<FestivalProvider>(
          create: (context) => FestivalProvider(),
        ),
        ChangeNotifierProvider<AssetProvider>(
          create: (context) => AssetProvider(),
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create: (context) => ReviewProvider(),
        ),
        ChangeNotifierProvider<TicketProvider>(
          create: (context) => TicketProvider(),
        ),
        ChangeNotifierProvider<SubcategoryProvider>(
          create: (context) => SubcategoryProvider(),
        ),
        ChangeNotifierProvider<BusinessReportProvider>(
          create: (context) => BusinessReportProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ManiFest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A), // Purple
          primary: const Color(0xFF6A1B9A), // Purple
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
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

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final username = usernameController.text;
      final password = passwordController.text;

      AuthProvider.username = username;
      AuthProvider.password = password;

      final userProvider = context.read<UserProvider>();
      final user = await userProvider.authenticate(username, password);

      if (user != null) {
        bool hasAdminRole = user.roles.any((role) => role.id == 1);

        if (hasAdminRole) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CityListScreen(),
                settings: const RouteSettings(name: 'CityListScreen'),
              ),
            );
          }
        } else {
          if (mounted) {
            _showAccessDeniedDialog();
          }
        }
      } else {
        if (mounted) {
          _showErrorDialog("Invalid username or password.");
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      }
    } catch (e) {
      print(e);
      if (mounted) {
        _showErrorDialog("An unexpected error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Login Failed"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Access Denied"),
        content: const Text("You do not have administrator privileges."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              usernameController.clear();
              passwordController.clear();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side - Visual Branding (60%)
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A), // Dark Blue
                    Color(0xFF2563EB), // Primary Blue
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative Circles
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // Centered Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              "assets/images/3.png",
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "ParkHere",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Smart Parking Management System",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side - Login Form (40%)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(40),
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E3A8A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please sign in to your dashboard",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 48),
                          
                          // Username
                          TextField(
                            controller: usernameController,
                            decoration: customTextFieldDecoration(
                              "Username",
                              prefixIcon: Icons.person_outline,
                              hintText: "Enter your username",
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Password
                          TextField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: customTextFieldDecoration(
                              "Password",
                              prefixIcon: Icons.lock_outline,
                              hintText: "Enter your password",
                              suffixIcon: _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {}, // Implement forgot password
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                              ),
                              child: const Text("Forgot Password?"),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Login Button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
