import 'dart:convert';
import 'package:parkhere_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'package:parkhere_mobile/model/parking_reservation.dart';
import 'package:parkhere_mobile/providers/parking_session_provider.dart';
import 'package:parkhere_mobile/providers/user_provider.dart';
import 'package:parkhere_mobile/layouts/master_screen.dart';
import 'package:parkhere_mobile/screens/home_screen.dart';
import 'package:parkhere_mobile/utils/base_textfield.dart'; 
import 'package:parkhere_mobile/utils/message_utils.dart';
import 'package:parkhere_mobile/utils/review_dialog.dart';

class PaymentScreen extends StatefulWidget {
  final ParkingReservation reservation;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.reservation,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _paymentCompleted = false;
  bool _isUsingMockPayment = false;

  @override
  void initState() {
    super.initState();
    debugPrint('--- PaymentScreen INIT ---');
    debugPrint('Incoming Total Price: ${widget.totalPrice}');
    debugPrint('Res Base Price: ${widget.reservation.price}');
    debugPrint('--------------------------');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.mainBackground,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Stack(
              children: [
                // Circular accents
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.03),
                    ),
                  ),
                ),
                
                _paymentCompleted
                    ? _buildPaymentSuccessScreen()
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: _buildPaymentForm(context),
                      ),
              ],
            ),
    );
  }

  Widget _buildPaymentSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 100,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Departure Confirmed',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 30,
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Payment of ${widget.totalPrice.toStringAsFixed(2)} BAM processed successfully. Safe travels!',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 56),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: "Return to Home",
                icon: Icons.home_rounded,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MasterScreen(
                        child: SizedBox.shrink(),
                        title: 'ParkHere',
                      ),
                      settings: const RouteSettings(name: 'MasterScreen'),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Summary",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  Text("Verify your session details", style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          
          _buildElegantAmountCard(),
          const SizedBox(height: 24),
          
          _buildSectionTitle("Session Details"),
          const SizedBox(height: 12),
          _buildDetailsGlassCard(),
          
          const SizedBox(height: 32),
          _buildSectionTitle("Billing Information"),
          const SizedBox(height: 12),
          _buildBillingForm(),
          
          const SizedBox(height: 48),
          _buildSecureSubmitButton(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.textLight,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildElegantAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "TOTAL TO PAY",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "BAM ",
                style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold, height: 2),
              ),
              Text(
                widget.totalPrice.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, color: Colors.greenAccent, size: 14),
                const SizedBox(width: 8),
                Text(
                  "SECURE PAYMENT",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGlassCard() {
    final now = DateTime.now();
    final arrivalTime = (widget.reservation.actualStartTime != null && widget.reservation.actualStartTime!.isBefore(widget.reservation.startTime))
        ? widget.reservation.actualStartTime!
        : widget.reservation.startTime;
        
    final departureTime = now.isAfter(widget.reservation.endTime)
        ? now
        : widget.reservation.endTime;

    final multiplier = widget.reservation.parkingSpot?.priceMultiplier ?? 1.0;
    final hourlyRate = 3.0 * multiplier;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          _buildCleanDetailRow("Vehicle", widget.reservation.vehicle?.licensePlate ?? "N/A", icon: Icons.directions_car_rounded),
          _buildDivider(),
          _buildCleanDetailRow("Parking Spot", widget.reservation.parkingSpot?.name ?? "N/A", icon: Icons.local_parking_rounded),
          _buildDivider(),
          _buildCleanDetailRow("Arrival", DateFormat('MMM dd, HH:mm').format(arrivalTime), icon: Icons.login_rounded),
          _buildDivider(),
          _buildCleanDetailRow("Departure", DateFormat('MMM dd, HH:mm').format(departureTime), icon: Icons.logout_rounded),
          _buildDivider(),
          _buildCleanDetailRow("Base Hourly", "${hourlyRate.toStringAsFixed(2)} BAM/hr", icon: Icons.query_builder_rounded),
          if (widget.totalPrice > widget.reservation.price) ...[
            _buildDivider(),
            _buildCleanDetailRow("Overtime Fee", "${(widget.totalPrice - widget.reservation.price).toStringAsFixed(2)} BAM", isRed: true, icon: Icons.history_rounded),
          ]
        ],
      ),
    );
  }

  Widget _buildCleanDetailRow(String label, String value, {bool isRed = false, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey[100]!)),
             child: Icon(icon, size: 16, color: AppColors.primary.withOpacity(0.7)),
           ),
           const SizedBox(width: 16),
           Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w500)),
           const Spacer(),
           Text(
             value,
             style: TextStyle(
               color: isRed ? Colors.redAccent : AppColors.primaryDark,
               fontSize: 14,
               fontWeight: FontWeight.bold,
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 20), height: 1, color: Colors.grey[100]);
  }

  Widget _buildBillingForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          AppTextField(
            label: "Full Name",
            controller: TextEditingController(text: _getUserFullName()),
            prefixIcon: Icons.person_outline_rounded,
            hintText: "As it appears on card",
          ),
          // We could add more fields if needed, but keeping it clean as per user request
        ],
      ),
    );
  }

  String _getUserFullName() {
    final user = UserProvider.currentUser;
    if (user != null) {
      return '${user.firstName} ${user.lastName}';
    }
    return 'Guest User';
  }

  Widget _buildSecureSubmitButton(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: AppButton(
            text: "Unlock Ramp & Exit",
            icon: Icons.lock_open_rounded,
            onPressed: () async {
               // Initial logic: in a real app check formKey validation
               try {
                  await _processStripePayment({});
               } catch (e) {
                  MessageUtils.showError(context, 'Payment failed: ${e.toString()}');
               }
            },
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, color: Colors.green, size: 14),
            SizedBox(width: 8),
            Text("Payments are 256-bit encrypted", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Future<bool> _initPaymentSheet(Map<String, dynamic> formData) async {
    try {
      final name = formData['name'] ?? _getUserFullName();
      final data = await _createPaymentIntent(
        amount: (widget.totalPrice * 100).round().toString(),
        currency: 'USD',
        name: name,
      );

      final isMock = data['client_secret'].toString().contains('mock');
      setState(() => _isUsingMockPayment = isMock);
      
      if (isMock) {
        debugPrint('Initialized in MOCK mode');
        return true; // Is mock
      }

      debugPrint('Initializing REAL Stripe sheet');
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'ParkHere',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.light,
        ),
      );
      return false; // Is real
    } catch (e) {
      debugPrint('Error initializing payment sheet: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent({
    required String amount,
    required String currency,
    required String name,
  }) async {
    try {
      final secretKey = dotenv.env['STRIPE_SECRET_KEY'];
      if(secretKey == null || secretKey.isEmpty) {
         return _createMockPaymentIntent(amount, currency);
      }

      final customerResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'email': UserProvider.currentUser?.email ?? 'user@parkhere.com',
        },
      );

      if (customerResponse.statusCode != 200) return _createMockPaymentIntent(amount, currency);
      final customerData = jsonDecode(customerResponse.body);
      final customerId = customerData['id'];

      final ephemeralKeyResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/ephemeral_keys'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Stripe-Version': '2023-10-16',
        },
        body: {'customer': customerId},
      );

      if (ephemeralKeyResponse.statusCode != 200) return _createMockPaymentIntent(amount, currency);
      final ephemeralKeyData = jsonDecode(ephemeralKeyResponse.body);

      final paymentIntentResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency.toLowerCase(),
          'customer': customerId,
          'payment_method_types[]': 'card',
          'description': 'ParkHere Exit Fee - Res #${widget.reservation.id}',
        },
      );

      if (paymentIntentResponse.statusCode == 200) {
        final paymentIntentData = jsonDecode(paymentIntentResponse.body);
        return {
          'client_secret': paymentIntentData['client_secret'],
          'ephemeralKey': ephemeralKeyData['secret'],
          'id': customerId,
        };
      } else {
        final errorData = jsonDecode(paymentIntentResponse.body);
        final stripeMsg = errorData['error']?['message'] ?? 'Unknown Stripe error';
        throw Exception("Stripe Payment Intent Failed: $stripeMsg");
      }
    } catch (e) {
      if (dotenv.env['STRIPE_SECRET_KEY']?.isNotEmpty ?? false) {
        rethrow; // Don't mock if we have a key but it failed
      }
      return _createMockPaymentIntent(amount, currency);
    }
  }

  Map<String, dynamic> _createMockPaymentIntent(String amount, String currency) {
    return {
      'client_secret': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}_secret_mock',
      'ephemeralKey': 'ek_mock_${DateTime.now().millisecondsSinceEpoch}',
      'id': 'cus_mock_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  Future<void> _processStripePayment(Map<String, dynamic> formData) async {
    // 1. Check for Stripe minimum limit (approx $0.50)
    if (widget.totalPrice > 0 && widget.totalPrice < 0.50) {
      debugPrint('Amount too small for Stripe, forcing simulation');
      setState(() => _isUsingMockPayment = true);
      _showMockPaymentConfirmation(isSmallAmount: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Initialize the sheet and determine if it's mock
      final isMock = await _initPaymentSheet(formData);
      
      if (!isMock) {
        // 3. Present real Stripe UI
        debugPrint('Presenting Stripe Payment Sheet...');
        await stripe.Stripe.instance.presentPaymentSheet();
        
        // 4. Finalize after real payment success
        await _finalizeExit();

        if (mounted) {
          MessageUtils.showSuccess(context, 'Payment successful! Ramp opened.');
          setState(() {
              _isLoading = false;
              _paymentCompleted = true;
          });
          _triggerReviewFlow();
        }
      } else {
        // 5. Present Simulation Dialog
        debugPrint('Showing Simulation Dialog...');
        setState(() => _isLoading = false);
        _showMockPaymentConfirmation();
      }
    } on stripe.StripeException catch (e) {
      setState(() => _isLoading = false);
      if (e.error.code == 'canceled') {
        MessageUtils.showWarning(context, 'Payment session closed');
      } else {
        MessageUtils.showError(context, 'Stripe Error: ${e.error.message}');
      }
    } catch (e) {
      debugPrint('Non-Stripe Error in payment flow: $e');
      setState(() => _isLoading = false);
      
      // If we failed during REAL setup but want to allow fallback IF mock was intended
      if (_isUsingMockPayment) {
         _showMockPaymentConfirmation();
      } else {
         MessageUtils.showError(context, 'Payment Error: ${e.toString()}');
      }
    }
  }

  void _showMockPaymentConfirmation({bool isSmallAmount = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isSmallAmount ? "Small Amount" : "Simulate Payment"),
        content: Text(isSmallAmount 
          ? "The amount of ${widget.totalPrice.toStringAsFixed(2)} BAM is below the minimum card transaction limit (0.50 BAM). Would you like to process this via simulation?"
          : "Stripe keys are not configured. Would you like to simulate a successful payment of ${widget.totalPrice.toStringAsFixed(2)} BAM?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLoading = false);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _finalizeExit();
                if (mounted) {
                  MessageUtils.showSuccess(context, 'Simulated payment successful!');
                  setState(() {
                    _isLoading = false;
                    _paymentCompleted = true;
                  });
                  _triggerReviewFlow();
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  MessageUtils.showError(context, "Exit failed: $e");
                }
              }
            },
            child: const Text("Confirm Payment"),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeExit() async {
    try {
      final sessionProvider = Provider.of<ParkingSessionProvider>(context, listen: false);
      await sessionProvider.setActualEndTime(widget.reservation.id);
      await sessionProvider.markAsPaid(widget.reservation.id);
    } catch (e) {
      throw Exception('Failed to finalize exit: $e');
    }
  }

  void _triggerReviewFlow() {
    final resId = widget.reservation.id;
    debugPrint('Review flow scheduled for Reservation #$resId in 5 seconds...');
    Future.delayed(const Duration(seconds: 5), () {
      final context = MyApp.navigatorKey.currentContext;
      if (context != null) {
        debugPrint('Triggering ReviewDialog for Reservation #$resId using global context');
        showDialog(
          context: context,
          builder: (context) => ReviewDialog(reservationId: resId),
        );
      } else {
        debugPrint('Could not trigger ReviewDialog: internal context is null');
      }
    });
  }
}
