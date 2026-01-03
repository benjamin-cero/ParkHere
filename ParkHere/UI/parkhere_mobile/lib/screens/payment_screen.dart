import 'dart:convert';
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

  final commonDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primary, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exit Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.mainBackground,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _paymentCompleted
              ? _buildPaymentSuccessScreen()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildPaymentForm(context),
                ),
    );
  }

  Widget _buildPaymentSuccessScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.primaryDark.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your parking session has ended and payment is confirmed.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Reservation ID: ${widget.reservation.id}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildReservationDetailsCard(),
          const SizedBox(height: 32),
          AppButton(
            text: "Back to Home",
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
        ],
      ),
    );
  }

  Widget _buildReservationDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Vehicle', widget.reservation.vehicle?.licensePlate ?? 'N/A'),
                const SizedBox(height: 12),
                _buildSummaryRow('Spot', widget.reservation.parkingSpot?.name ?? 'Spot #${widget.reservation.parkingSpotId}'),
                const SizedBox(height: 12),
                _buildSummaryRow('Entry Time', DateFormat('MMM dd, HH:mm').format(widget.reservation.actualStartTime ?? widget.reservation.startTime)),
                const SizedBox(height: 12),
                _buildSummaryRow('Exit Time', DateFormat('MMM dd, HH:mm').format(DateTime.now())),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Total Amount',
                  '${widget.totalPrice.toStringAsFixed(2)} BAM',
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.text : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentForm(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountCard(),
          const SizedBox(height: 24),
          _buildReservationDetailsSection(),
          const SizedBox(height: 24),
          _buildBillingSection(),
          const SizedBox(height: 32),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.mainBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Total Amount due',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${widget.totalPrice.toStringAsFixed(2)} BAM',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Parking Exit Fee',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Session Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Vehicle', widget.reservation.vehicle?.licensePlate ?? 'N/A'),
          const SizedBox(height: 12),
          _buildDetailRow('Parking Spot', widget.reservation.parkingSpot?.name ?? 'Spot #${widget.reservation.parkingSpotId}'),
          const SizedBox(height: 12),
          _buildDetailRow('Started At', DateFormat('MMM dd, HH:mm').format(widget.reservation.actualStartTime ?? widget.reservation.startTime)),
          const SizedBox(height: 12),
          _buildDetailRow('Base Price', '${widget.reservation.price.toStringAsFixed(2)} BAM'),
          if (widget.totalPrice > widget.reservation.price) ...[
            const SizedBox(height: 12),
            _buildDetailRow('Overtime Charge', '${(widget.totalPrice - widget.reservation.price).toStringAsFixed(2)} BAM'),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildBillingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Billing Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'name',
            'Full Name',
            initialValue: _getUserFullName(),
          ),
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

  Widget _buildTextField(
    String name,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    bool isNumeric = false,
    String? initialValue,
  }) {
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      decoration: commonDecoration.copyWith(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
      validator: isNumeric
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.numeric(),
            ])
          : FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
      keyboardType: keyboardType,
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return AppButton(
      text: "Pay & Exit Parking",
      icon: Icons.lock_outline_rounded,
      onPressed: () async {
        if (formKey.currentState?.saveAndValidate() ?? false) {
          final formData = formKey.currentState?.value;
          try {
            await _processStripePayment(formData!);
          } catch (e) {
            MessageUtils.showError(context, 'Payment failed: ${e.toString()}');
          }
        }
      },
    );
  }

  Future<void> _initPaymentSheet(Map<String, dynamic> formData) async {
    try {
      final data = await _createPaymentIntent(
        amount: (widget.totalPrice * 100).round().toString(),
        currency: 'USD',
        name: formData['name'] ?? 'Guest User',
      );

      final isMock = data['client_secret'].toString().contains('mock');
      _isUsingMockPayment = isMock;
      
      if (isMock) {
        print('Using mock payment intent');
        return;
      }

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
    } catch (e) {
      print('Error initializing payment sheet: $e');
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
        return _createMockPaymentIntent(amount, currency);
      }
    } catch (e) {
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
    setState(() => _isLoading = true);

    try {
      await _initPaymentSheet(formData);
      
      if (!_isUsingMockPayment) {
        await stripe.Stripe.instance.presentPaymentSheet();
      }

      await _finalizeExit();

      if (mounted) {
        setState(() {
            _isLoading = false;
            _paymentCompleted = true;
        });
      }
    } on stripe.StripeException catch (e) {
      setState(() => _isLoading = false);
      if (e.error.code == 'canceled') {
        MessageUtils.showWarning(context, 'Payment was canceled');
      } else {
        MessageUtils.showError(context, 'Payment failed: ${e.error.message ?? e.toString()}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('canceled')) {
        MessageUtils.showWarning(context, 'Payment was canceled');
      } else {
        // Fallback for demo
        try {
           await _finalizeExit();
           if (mounted) {
             setState(() {
               _isLoading = false;
               _paymentCompleted = true;
             });
           }
        } catch (exitError) {
          MessageUtils.showError(context, 'Error finalizing exit: ${exitError.toString()}');
        }
      }
    }
  }

  Future<void> _finalizeExit() async {
    try {
      final sessionProvider = Provider.of<ParkingSessionProvider>(context, listen: false);
      
      // 1. Set actual end time (calculates everything on server)
      await sessionProvider.setActualEndTime(widget.reservation.id);
      
      // 2. Mark as paid
      await sessionProvider.markAsPaid(widget.reservation.id);
      
    } catch (e) {
      throw Exception('Failed to finalize exit: $e');
    }
  }
}
