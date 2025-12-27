import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/ticket.dart';
import 'package:parkhere_desktop/utils/qr_generator.dart';

class TicketDetailsScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Ticket Details',
      showBackButton: true,
      child: _buildTicketDetails(context),
    );
  }

  Widget _buildTicketDetails(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Card (narrow, centered)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // QR Code instead of icon
                      QRGenerator.generateQRCode(ticket.qrCodeData, size: 80),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ticket #${ticket.id}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticket.festivalTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ticket.isRedeemed ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ticket.isRedeemed ? 'Redeemed' : 'Active',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Info Card (narrow, centered)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(
                        context,
                        'Ticket Information',
                        Icons.info_outline,
                        [
                          _buildInfoRow('Ticket Type', ticket.ticketTypeName),
                          _buildInfoRow(
                            'Final Price',
                            '\$${ticket.finalPrice.toStringAsFixed(2)}',
                          ),
                          _buildInfoRow(
                            'Created At',
                            _formatDate(ticket.createdAt),
                          ),
                          if (ticket.redeemedAt != null)
                            _buildInfoRow(
                              'Redeemed At',
                              _formatDate(ticket.redeemedAt!),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        context,
                        'User Information',
                        Icons.person,
                        [
                          _buildInfoRow('Full Name', ticket.userFullName),
                          _buildInfoRow('Username', ticket.username),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        context,
                        'Festival Information',
                        Icons.festival,
                        [_buildInfoRow('Festival Title', ticket.festivalTitle)],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        context,
                        'Ticket Codes',
                        Icons.qr_code,
                        [_buildInfoRow('Redeem Code', ticket.textCode)],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> infoRows,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...infoRows,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // label width
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
