import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/event_provider.dart';
import '../services/auth_provider.dart';
import 'event_bookings_screen.dart';

class OrganizerEventsScreen extends StatelessWidget {
  const OrganizerEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final myEvents = eventProvider.events.where((e) => e.organizerId == authProvider.user?.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: myEvents.isEmpty
          ? const Center(child: Text('You haven\'t created any events yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myEvents.length,
              itemBuilder: (context, index) {
                final event = myEvents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        event.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: Colors.grey[200], width: 60, height: 60),
                      ),
                    ),
                    title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${event.date} • ${event.availableSeats} seats left'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.people_outline, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventBookingsScreen(event: event),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Event'),
                                content: const Text('Are you sure you want to delete this event?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('NO')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('YES')),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await eventProvider.deleteEvent(event.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
