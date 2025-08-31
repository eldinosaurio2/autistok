import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:autistock/services/data_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

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

  Uint8List? _imageBytes;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _otherGenderController.addListener(() {
      if (mounted) {
        setState(() {
          // Rebuild to show updated text
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthYearController.dispose();
    _otherGenderController.dispose();
    super.dispose();
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
        try {
          _imageBytes = base64Decode(imagePath);
        } catch (e) {
          print("Error decoding base64 image: $e");
          _imageBytes = null;
        }
      });
    }
  }

  Future<void> _shareProfile() async {
    final name = _nameController.text;
    final birthYear = _birthYearController.text;
    String genderText;

    if (_gender == 'male') {
      genderText = 'Masculino';
    } else if (_gender == 'female') {
      genderText = 'Femenino';
    } else if (_gender == 'other') {
      genderText = _otherGenderController.text.isNotEmpty
          ? _otherGenderController.text
          : 'Otro';
    } else {
      genderText = 'No especificado';
    }

    final profileSummary = '''
      Nombre: $name
      Año de Nacimiento: $birthYear
      Género: $genderText
    ''';

    await Share.share(profileSummary, subject: 'Mi Perfil de Autistock');
  }

  Future<void> _getImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
      await _saveProfileImageWeb(bytes);
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

  Future<void> _saveProfileImage(String path) async {
    final dataService = Provider.of<DataService>(context, listen: false);
    await dataService.setProfileImagePath(path);
  }

  Future<void> _saveProfileImageWeb(Uint8List bytes) async {
    final base64Image = base64Encode(bytes);
    await _saveProfileImage(base64Image);
  }

  void _showOtherGenderDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Otro género'),
          content: TextField(
            controller: _otherGenderController,
            decoration:
                const InputDecoration(hintText: "Especifique su género"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _saveProfileData();
                if (!mounted) return;
                Navigator.of(dialogContext).pop();
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
                  backgroundImage:
                      _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                  child: _imageBytes == null
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _saveProfileData();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil guardado')),
                      );
                    },
                    child: const Text('Guardar'),
                  ),
                  ElevatedButton(
                    onPressed: _shareProfile,
                    child: const Text('Compartir'),
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
