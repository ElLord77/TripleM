// lib/screens/slot_status_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database

class SlotStatusScreen extends StatefulWidget {
  final String slotName;

  // Constructor now only requires slotName
  const SlotStatusScreen({Key? key, required this.slotName}) : super(key: key);

  @override
  State<SlotStatusScreen> createState() => _SlotStatusScreenState();
}

class _SlotStatusScreenState extends State<SlotStatusScreen> {
  bool _currentIsOccupied = false; // Default status
  bool _isLoading = true; // For initial status fetching
  // _isBookingLoading and _handleBooking are removed

  // Mapping from app slot names to RTDB keys
  final Map<String, String> _slotNameToRtdbKey = {
    'B1': 'slot1',
    'B2': 'slot2',
    'B5': 'slot3',
    'B6': 'slot4',
  };

  @override
  void initState() {
    super.initState();
    _fetchSlotStatus();
  }

  Future<void> _fetchSlotStatus() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    bool fetchedStatus = false;

    if (_slotNameToRtdbKey.containsKey(widget.slotName)) {
      String rtdbSlotKey = _slotNameToRtdbKey[widget.slotName]!;
      DatabaseReference slotRef = FirebaseDatabase.instance.ref('$rtdbSlotKey/occupied');

      try {
        final snapshot = await slotRef.get();
        if (snapshot.exists && snapshot.value != null) {
          if (snapshot.value is bool) {
            fetchedStatus = snapshot.value as bool;
          } else if (snapshot.value is String) {
            fetchedStatus = (snapshot.value as String).toLowerCase() == 'true';
          } else {
            print('Warning: Slot ${widget.slotName} ($rtdbSlotKey/occupied) has an unexpected data type: ${snapshot.value.runtimeType}. Defaulting to empty.');
          }
        } else {
          print('Warning: Slot ${widget.slotName} ($rtdbSlotKey/occupied) not found in RTDB or has no value. Defaulting to empty.');
        }
      } catch (error) {
        print('Error fetching status for ${widget.slotName}: $error. Defaulting to empty.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not fetch status for ${widget.slotName}.')),
          );
        }
      }
    } else {
      // Slot is not B1, B2, B5, B6, so it's always considered empty
      await Future.delayed(const Duration(milliseconds: 50)); // Short delay for consistent UX
    }

    if (mounted) {
      setState(() {
        _currentIsOccupied = fetchedStatus;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status for Slot: ${widget.slotName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Parking Slot:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                widget.slotName,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Text(
                'Status:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: _currentIsOccupied ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _currentIsOccupied ? Colors.red.shade300 : Colors.green.shade300,
                      width: 2,
                    )
                ),
                child: Text(
                  _currentIsOccupied ? 'Occupied' : 'Empty',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _currentIsOccupied ? Colors.red.shade800 : Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 50), // Space before the Go Back button
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Go back
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
