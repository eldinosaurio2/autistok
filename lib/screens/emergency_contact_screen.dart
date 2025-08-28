import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact.dart';
import '../services/data_service.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  List<EmergencyContact> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadEmergencyContacts() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final contacts = await dataService.loadEmergencyContacts();
    if (mounted) {
      setState(() {
        _emergencyContacts = contacts;
      });
    }
  }

  Future<void> _saveEmergencyContact() async {
    if (_formKey.currentState!.validate()) {
      final dataService = Provider.of<DataService>(context, listen: false);
      final newContact = EmergencyContact(
        name: _nameController.text,
        phone: _phoneController.text,
      );

      setState(() {
        _emergencyContacts.add(newContact);
      });

      await dataService.saveEmergencyContacts(_emergencyContacts);

      _nameController.clear();
      _phoneController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacto de emergencia guardado')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _deleteEmergencyContact(EmergencyContact contact) async {
    final dataService = Provider.of<DataService>(context, listen: false);
    setState(() {
      _emergencyContacts.remove(contact);
    });
    await dataService.saveEmergencyContacts(_emergencyContacts);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacto de emergencia eliminado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos de Emergencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _emergencyContacts.isEmpty
                  ? const Center(child: Text('No hay contactos de emergencia.'))
                  : ListView.builder(
                      itemCount: _emergencyContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _emergencyContacts[index];
                        return Card(
                          child: ListTile(
                            title: Text(contact.name),
                            subtitle: Text(contact.phone),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.call),
                                  onPressed: () =>
                                      _makePhoneCall(contact.phone),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteEmergencyContact(contact),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Añadir nuevo contacto',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un nombre';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un teléfono';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveEmergencyContact,
                    child: const Text('Añadir Contacto'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
