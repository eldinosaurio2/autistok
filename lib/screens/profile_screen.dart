import 'dart:io';
import 'package:autistock/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _birthYearController = TextEditingController();
  String? _gender;
  final _otherGenderController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    _nameController.text = await dataService.getProfileName();
    _birthYearController.text = await dataService.getBirthYear();
    _gender = await dataService.getGender();
    if (_gender == 'other') {
      _otherGenderController.text = await dataService.getOtherGender();
    }
    final imagePath = await dataService.getProfileImagePath();
    if (imagePath != null) {
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  Future<void> _saveProfileData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    await dataService.saveProfileName(_nameController.text);
    await dataService.saveBirthYear(_birthYearController.text);
    if (_gender != null) {
      await dataService.saveGender(_gender!);
      if (_gender == 'other') {
        await dataService.saveOtherGender(_otherGenderController.text);
      }
    }
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _saveProfileImage(pickedFile.path);
    }
  }

  Future<void> _saveProfileImage(String path) async {
    final dataService = Provider.of<DataService>(context, listen: false);
    await dataService.setProfileImagePath(path);
  }

  void _showOtherGenderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Otro género'),
          content: TextField(
            controller: _otherGenderController,
            decoration:
                const InputDecoration(hintText: "Especifique su género"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveProfileData();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _getImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _birthYearController,
                decoration:
                    const InputDecoration(labelText: 'Año de Nacimiento'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Género',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    padding: const EdgeInsets.all(8.0),
                    avatar: Icon(Icons.male,
                        color: _gender == 'male'
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface),
                    label: const Text('Masculino'),
                    selected: _gender == 'male',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _gender = 'male';
                        });
                        _saveProfileData();
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                  ),
                  ChoiceChip(
                    padding: const EdgeInsets.all(8.0),
                    avatar: Icon(Icons.female,
                        color: _gender == 'female'
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface),
                    label: const Text('Femenino'),
                    selected: _gender == 'female',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _gender = 'female';
                        });
                        _saveProfileData();
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                  ),
                  ChoiceChip(
                    padding: const EdgeInsets.all(8.0),
                    avatar: Icon(Icons.help_outline,
                        color: _gender == 'other'
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface),
                    label: const Text('Otro'),
                    selected: _gender == 'other',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _gender = 'other';
                        });
                        _showOtherGenderDialog();
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            if (_gender == 'other')
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Text(
                  'Género especificado: ${_otherGenderController.text}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  _saveProfileData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil guardado')),
                  );
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
