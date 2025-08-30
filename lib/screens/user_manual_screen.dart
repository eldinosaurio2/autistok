import 'package:flutter/material.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual de Usuario'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Bienvenido al manual de usuario de Autistock.\n\n'
              'Aquí encontrarás una guía para utilizar todas las funcionalidades de la aplicación:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('1. Pantalla de Inicio'),
            _buildSectionContent(
              'La pantalla de inicio te da acceso rápido a todas las secciones de la aplicación. Los botones se reordenan automáticamente según la frecuencia de uso para que encuentres más rápido lo que más utilizas.',
            ),
            _buildSectionTitle('2. Registro de Estado de Ánimo'),
            _buildSectionContent(
              'Puedes registrar tu estado de ánimo diario utilizando pictogramas que representan diferentes emociones. Esto te ayudará a llevar un seguimiento de cómo te sientes a lo largo del tiempo.',
            ),
            _buildSectionTitle('3. Sistema de Recompensas'),
            _buildSectionContent(
              'Gana puntos y desbloquea logros al utilizar la aplicación de forma consistente. ¡Registrar tu estado de ánimo y completar actividades te dará recompensas!',
            ),
            _buildSectionTitle('4. Regulación'),
            _buildSectionContent(
              'Esta sección ofrece ejercicios de respiración y "grounding" (anclaje) para ayudarte a manejar momentos de estrés o ansiedad. Sigue las instrucciones en pantalla para relajarte.',
            ),
            _buildSectionTitle('5. Contacto de Emergencia'),
            _buildSectionContent(
              'Guarda un contacto de emergencia al que puedas llamar rápidamente desde la aplicación en caso de necesidad.',
            ),
            _buildSectionTitle('6. Calendario'),
            _buildSectionContent(
              'Organiza tus actividades y eventos en el calendario. Próximamente, podrás ver tus registros de ánimo y actividades planificadas.',
            ),
            _buildSectionTitle('7. Configuración'),
            _buildSectionContent(
              'Personaliza tu experiencia en la aplicación. Puedes cambiar entre el tema claro y oscuro, y ajustar el tamaño del texto para una mejor lectura. También puedes gestionar las notificaciones de la aplicación, incluyendo un interruptor global para activarlas o desactivarlas, y ajustes individuales para los recordatorios de estado de ánimo, recordatorios de actividades y notificaciones de recompensas. Ten en cuenta que las notificaciones solo están disponibles en la versión móvil de la aplicación (iOS/Android).',
            ),
            _buildSectionTitle('8. Botón de Apagado'),
            _buildSectionContent(
              'En la esquina superior derecha de la pantalla principal, encontrarás un botón para cerrar la aplicación de forma rápida y segura.',
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
