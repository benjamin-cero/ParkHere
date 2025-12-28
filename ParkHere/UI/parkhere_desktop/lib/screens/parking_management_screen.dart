import 'package:flutter/material.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/parking_sector.dart';
import 'package:parkhere_desktop/model/parking_wing.dart';
import 'package:parkhere_desktop/model/parking_spot.dart';
import 'package:parkhere_desktop/model/parking_spot_type.dart';
import 'package:parkhere_desktop/providers/parking_sector_provider.dart';
import 'package:parkhere_desktop/providers/parking_wing_provider.dart';
import 'package:parkhere_desktop/providers/parking_spot_provider.dart';
import 'package:parkhere_desktop/providers/parking_spot_type_provider.dart';
import 'package:provider/provider.dart';

class ParkingManagementScreen extends StatefulWidget {
  const ParkingManagementScreen({super.key});

  @override
  State<ParkingManagementScreen> createState() =>
      _ParkingManagementScreenState();
}

class _ParkingManagementScreenState extends State<ParkingManagementScreen> {
  late ParkingSectorProvider _sectorProvider;
  late ParkingWingProvider _wingProvider;
  late ParkingSpotProvider _spotProvider;
  late ParkingSpotTypeProvider _spotTypeProvider;

  List<ParkingSector> _sectors = [];
  ParkingSector? _selectedSector;
  List<ParkingWing> _wings = [];
  Map<int, List<ParkingSpot>> _spotsByWing = {};
  List<ParkingSpotType> _spotTypes = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _sectorProvider = context.read<ParkingSectorProvider>();
    _wingProvider = context.read<ParkingWingProvider>();
    _spotProvider = context.read<ParkingSpotProvider>();
    _spotTypeProvider = context.read<ParkingSpotTypeProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Load Sectors and Types
      final sectorsResult = await _sectorProvider.get();
      final typesResult = await _spotTypeProvider.get();
      _sectors = sectorsResult.items ?? [];
      _spotTypes = typesResult.items ?? [];

      if (_sectors.isNotEmpty) {
        _selectedSector = _sectors.first;
        await _loadSectorDetails(_selectedSector!.id);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error loading data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSectorDetails(int sectorId) async {
    try {
      // 2. Load Wings for Sector
      final wingsResult =
          await _wingProvider.get(filter: {'parkingSectorId': sectorId});
      _wings = wingsResult.items ?? [];

      // 3. Load Spots for each Wing
      _spotsByWing.clear();
      for (var wing in _wings) {
        final spotsResult =
            await _spotProvider.get(filter: {'parkingWingId': wing.id});
        _spotsByWing[wing.id] = spotsResult.items ?? [];
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("Error loading sector details: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSectorStatus() async {
    if (_selectedSector == null) return;
    
    final newStatus = !_selectedSector!.isActive;
    final action = newStatus ? "aktivirati" : "deaktivirati";
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Potvrda"),
        content: Text("Da li želite $action sprat ${_selectedSector!.name}? Svi wingovi i spotovi će biti ${newStatus ? 'aktivirani' : 'deaktivirani'}."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Ne"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
            child: const Text("Da"),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      final modifiedSector = ParkingSector(
        id: _selectedSector!.id,
        floorNumber: _selectedSector!.floorNumber,
        name: _selectedSector!.name,
        isActive: newStatus,
      );

      final updated = await _sectorProvider.update(
          _selectedSector!.id, modifiedSector.toJson());
      
      // Update local state
      setState(() {
        _selectedSector = updated;
        int index = _sectors.indexWhere((s) => s.id == updated.id);
        if (index != -1) _sectors[index] = updated;
      });
      
      // Refresh details to show cascading changes
      await _loadSectorDetails(_selectedSector!.id);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sprat je uspješno ${newStatus ? 'aktiviran' : 'deaktiviran'}!"),
          backgroundColor: newStatus ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }
  Future<void> _toggleWingStatus(ParkingWing wing) async {
    final newStatus = !wing.isActive;
    final action = newStatus ? "aktivirati" : "deaktivirati";
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Potvrda"),
        content: Text("Da li želite $action wing ${wing.name}? Svi spotovi u ovom wingu će biti ${newStatus ? 'aktivirani' : 'deaktivirani'}."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Ne"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
            child: const Text("Da"),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      final updated = await _wingProvider.update(wing.id,
          {'isActive': newStatus, 'name': wing.name, 'parkingSectorId': wing.parkingSectorId});
      
      setState(() {
        int index = _wings.indexWhere((w) => w.id == updated.id);
        if (index != -1) _wings[index] = updated;
      });
      
      // Refresh to show cascading changes
      await _loadSectorDetails(_selectedSector!.id);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Wing je uspješno ${newStatus ? 'aktiviran' : 'deaktiviran'}!"),
          backgroundColor: newStatus ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  Future<void> _editSpot(ParkingSpot spot) async {
    ParkingSpotType? selectedType = _spotTypes.firstWhere(
        (t) => t.id == spot.parkingSpotTypeId,
        orElse: () => _spotTypes.first);
    bool isActive = spot.isActive;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Spot ${spot.spotCode}"),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ParkingSpotType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: "Spot Type"),
                items: _spotTypes.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t.type));
                }).toList(),
                onChanged: (val) => setState(() => selectedType = val),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Active"),
                value: isActive,
                onChanged: (val) => setState(() => isActive = val),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _spotProvider.update(spot.id, {
                  'parkingSpotTypeId': selectedType!.id,
                  'isActive': isActive,
                  'spotCode': spot.spotCode,
                  'parkingWingId': spot.parkingWingId
                });
                Navigator.pop(context);
                _loadSectorDetails(_selectedSector!.id); // Reload to refresh UI
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error updating spot: $e")));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Parking Management",
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: const Color(0xFFF8FAFC), // Tech White/Grey Background
              child: Column(
                children: [
                  _buildModernHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildModernWingSection(
                              _wings.firstWhere((w) => w.name.contains("Left"), orElse: () => _wings.first), 
                              "Left Wing"
                          )),
                          const SizedBox(width: 32), // Spacious Gap
                          Expanded(child: _buildModernWingSection(
                             _wings.firstWhere((w) => w.name.contains("Right"), orElse: () => _wings.last),
                             "Right Wing"
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          // Floor Selector Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ParkingSector>(
                value: _selectedSector,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                items: _sectors.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text("${s.name} (Floor ${s.floorNumber})"),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() { _selectedSector = val; _isLoading = true; });
                    _loadSectorDetails(val.id);
                  }
                },
              ),
            ),
          ),
          const Spacer(),
          // Spot Type Legend
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem(Icons.local_parking_rounded, Colors.grey[400]!, "Standard"),
              const SizedBox(width: 16),
              _buildLegendItem(Icons.star_rounded, const Color(0xFFD97706), "VIP"),
              const SizedBox(width: 16),
              _buildLegendItem(Icons.bolt_rounded, const Color(0xFF059669), "Electric"),
              const SizedBox(width: 16),
              _buildLegendItem(Icons.accessible_forward_rounded, const Color(0xFF2563EB), "Handicapped"),
            ],
          ),
          const Spacer(),
          // Stats or Actions
          if (_selectedSector != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _toggleSectorStatus,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedSector!.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                       BoxShadow(
                         color: (_selectedSector!.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.3),
                         blurRadius: 12,
                         offset: const Offset(0,4)
                       )
                    ]
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedSector!.isActive ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                        color: Colors.white, size: 20
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedSector!.isActive ? "Sector Active" : "Sector Closed",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernWingSection(ParkingWing? wing, String title) {
    if (wing == null) return const SizedBox();
    
    final spots = _spotsByWing[wing.id] ?? [];
    spots.sort((a, b) => a.id.compareTo(b.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wing Header
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(wing.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
             const SizedBox(width: 8),
             Switch(
                value: wing.isActive,
                onChanged: (v) => _toggleWingStatus(wing),
                activeColor: Theme.of(context).primaryColor,
             )
          ],
        ),
        const SizedBox(height: 16),
        // Grid
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[100]!),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]
            ),
            padding: const EdgeInsets.all(24),
            child: GridView.builder(
              itemCount: spots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (ctx, index) => _ModernSpotCard(
                spot: spots[index],
                spotTypes: _spotTypes,
                onTap: () => _showModernEditPanel(spots[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showModernEditPanel(ParkingSpot spot) {
    // Determine current type safely
    ParkingSpotType selectedType = _spotTypes.firstWhere(
      (t) => t.id == spot.parkingSpotTypeId,
      orElse: () => _spotTypes.isNotEmpty ? _spotTypes.first : ParkingSpotType(type: "Standard", id: 0)
    );
    bool isActive = spot.isActive;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Edit Spot ${spot.spotCode}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))
                ],
              ),
              const SizedBox(height: 32),
              
              const Text("Spot Type", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _spotTypes.map((type) {
                  final isSelected = selectedType.id == type.id;
                  return ChoiceChip(
                    label: Text(type.type),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                    ),
                    onSelected: (selected) {
                      if (selected) setModalState(() => selectedType = type);
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              const Text("Status", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              SwitchListTile(
                 contentPadding: EdgeInsets.zero,
                 title: const Text("Spot is Active", style: TextStyle(fontWeight: FontWeight.bold)),
                 subtitle: const Text("Inactive spots cannot be booked."),
                 value: isActive,
                 activeColor: Theme.of(context).primaryColor,
                 onChanged: (val) => setModalState(() => isActive = val),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Check if status is changing
                    final statusChanging = isActive != spot.isActive;
                    
                    if (statusChanging) {
                      final action = isActive ? "aktivirati" : "deaktivirati";
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text("Potvrda"),
                          content: Text("Da li želite $action spot ${spot.spotCode}?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Ne"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              ),
                              child: const Text("Da"),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirmed != true) return;
                    }
                    
                    try {
                       await _spotProvider.update(spot.id, {
                        'parkingSpotTypeId': selectedType.id,
                        'isActive': isActive,
                        'spotCode': spot.spotCode,
                        'parkingWingId': spot.parkingWingId
                      });
                      Navigator.pop(context);
                      _loadSectorDetails(_selectedSector!.id);
                      
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Spot je uspješno ažuriran!"),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    } catch (e) {
                      print("Error updating: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Greška: $e")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  // Helper placeholders for removed methods if needed, or rely on existing ones being there.
  // We keep _toggleSectorStatus and _toggleWingStatus as defined earlier in the class.
  // Accessing them here assumes they are still present in the file above line 201.
}


class _ModernSpotCard extends StatefulWidget {
  final ParkingSpot spot;
  final List<ParkingSpotType> spotTypes;
  final VoidCallback onTap;

  const _ModernSpotCard({required this.spot, required this.spotTypes, required this.onTap});

  @override
  State<_ModernSpotCard> createState() => _ModernSpotCardState();
}

class _ModernSpotCardState extends State<_ModernSpotCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final typeName = widget.spotTypes
      .firstWhere((t) => t.id == widget.spot.parkingSpotTypeId, orElse: () => ParkingSpotType(type: "?"))
      .type;

    // Premium Color System
    Color bg = Colors.white;
    Color border = Colors.grey[200]!;
    Color iconColor = Colors.grey[400]!;
    IconData icon = Icons.local_parking_rounded;

    if (typeName == "VIP") {
      bg = const Color(0xFFFFFBEB); // Amber 50
      border = const Color(0xFFFCD34D); // Amber 300
      iconColor = const Color(0xFFD97706); // Amber 600
      icon = Icons.star_rounded;
    } else if (typeName == "Electric") {
       bg = const Color(0xFFECFDF5); // Emerald 50
       border = const Color(0xFF6EE7B7); // Emerald 300
       iconColor = const Color(0xFF059669); // Emerald 600
       icon = Icons.bolt_rounded;
    } else if (typeName == "Handicapped") {
       bg = const Color(0xFFEFF6FF); // Blue 50
       border = const Color(0xFF93C5FD); // Blue 300
       iconColor = const Color(0xFF2563EB); // Blue 600
       icon = Icons.accessible_forward_rounded;
    }

    if (widget.spot.isOccupied) {
       bg = const Color(0xFFFEF2F2); // Red 50
       border = const Color(0xFFFCA5A5); // Red 300
       iconColor = const Color(0xFFDC2626); // Red 600
    }
    
    if (!widget.spot.isActive) {
      bg = Colors.grey[100]!;
      border = Colors.transparent;
      iconColor = Colors.grey[300]!;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? Theme.of(context).primaryColor : border,
              width: _isHovered ? 2 : 1
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))
              else
                 BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: Stack(
            children: [
               // Status Indicator Dot
               Positioned(
                 top: 8, right: 8,
                 child: Container(
                   width: 6, height: 6,
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: widget.spot.isOccupied ? Colors.red : (widget.spot.isActive ? Colors.green : Colors.grey)
                   ),
                 ),
               ),
               
               Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Icon(
                       widget.spot.isOccupied ? Icons.directions_car_rounded : icon,
                       color: iconColor,
                       size: 20,
                     ),
                     const SizedBox(height: 4),
                     Text(
                       widget.spot.spotCode.split('-').last,
                       style: TextStyle(
                         fontSize: 10, 
                         fontWeight: FontWeight.bold, 
                         color: Colors.blueGrey[700],
                         decoration: !widget.spot.isActive ? TextDecoration.lineThrough : null
                       ),
                     )
                   ],
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}








