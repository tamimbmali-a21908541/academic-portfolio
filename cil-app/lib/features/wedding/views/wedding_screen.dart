import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/url_helper.dart';

class WeddingScreen extends StatefulWidget {
  const WeddingScreen({super.key});

  @override
  State<WeddingScreen> createState() => _WeddingScreenState();
}

class _WeddingScreenState extends State<WeddingScreen> {
  DateTime? _selectedDate;
  String _selectedPackage = 'basic';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casamento Islâmico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Ver no Website',
            onPressed: () {
              UrlHelper.openUrl(context, AppConstants.weddingUrl, title: 'Casamento - CIL');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.8),
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Nikah na Mesquita Central',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Introduction
            Text(
              'Sobre o Casamento Islâmico',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '''O Nikah (casamento islâmico) é uma cerimónia sagrada que une duas pessoas perante Deus. A Mesquita Central de Lisboa oferece um ambiente digno e solene para a realização desta importante celebração.

O nosso Imam conduz a cerimónia seguindo os preceitos islâmicos, incluindo:
• Recitação de versículos do Alcorão
• Khutbah (sermão) do casamento
• Troca de votos e consentimento
• Assinatura do contrato de casamento
• Dua (oração) pelos noivos''',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),

            // Packages
            Text(
              'Pacotes Disponíveis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPackages(context),
            const SizedBox(height: 24),

            // Requirements
            Text(
              'Documentos Necessários',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildRequirements(context),
            const SizedBox(height: 24),

            // Date Selection
            Text(
              'Marcar Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDateSelector(context),
            const SizedBox(height: 24),

            // Contact
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info, color: AppColors.info, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Precisa de mais informações?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contacte o nosso secretariado para esclarecer todas as suas dúvidas sobre o casamento islâmico.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppConstants.email,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDate != null ? () {
                  _showBookingConfirmation(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.secondary,
                ),
                child: Text(
                  _selectedDate != null ? 'Pedir Marcação' : 'Selecione uma data',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackages(BuildContext context) {
    final packages = [
      {
        'id': 'basic',
        'name': 'Cerimónia Simples',
        'price': '150€',
        'features': ['Cerimónia na sala de oração', 'Certificado de casamento', 'Até 30 convidados'],
      },
      {
        'id': 'premium',
        'name': 'Cerimónia Premium',
        'price': '300€',
        'features': ['Cerimónia no Salão Nobre', 'Certificado de casamento', 'Até 100 convidados', 'Decoração básica'],
      },
      {
        'id': 'complete',
        'name': 'Pacote Completo',
        'price': '500€',
        'features': ['Cerimónia no Salão Nobre', 'Certificado de casamento', 'Até 200 convidados', 'Decoração completa', 'Receção no refeitório'],
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        final isSelected = _selectedPackage == package['id'];

        return InkWell(
          onTap: () {
            setState(() {
              _selectedPackage = package['id'] as String;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? AppColors.secondary.withOpacity(0.05) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      package['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.secondary : null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        package['price'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...(package['features'] as List<String>).map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: isSelected ? AppColors.secondary : AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(feature, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirements(BuildContext context) {
    final requirements = [
      'Documento de identificação dos noivos',
      'Certidão de nascimento',
      'Declaração de estado civil',
      'Testemunhas (2 muçulmanos)',
      'Mahr (dote) acordado',
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: requirements.map((req) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.article, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(req)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
        title: Text(
          _selectedDate != null
              ? DateFormat('EEEE, dd MMMM yyyy', 'pt_PT').format(_selectedDate!)
              : 'Selecionar data',
        ),
        subtitle: _selectedDate != null ? null : const Text('Toque para escolher'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 30)),
            firstDate: DateTime.now().add(const Duration(days: 14)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            selectableDayPredicate: (date) {
              // Only allow Fridays, Saturdays, and Sundays
              return date.weekday >= 5;
            },
          );
          if (picked != null) {
            setState(() => _selectedDate = picked);
          }
        },
      ),
    );
  }

  void _showBookingConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.favorite, color: AppColors.secondary),
            SizedBox(width: 8),
            Text('Confirmar Marcação'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'),
            const SizedBox(height: 8),
            Text('Pacote: ${_getPackageName(_selectedPackage)}'),
            const SizedBox(height: 16),
            const Text(
              'Para completar a sua marcação, será redirecionado para o website da CIL.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              UrlHelper.openUrl(context, AppConstants.weddingUrl, title: 'Casamento - CIL');
            },
            child: const Text('Continuar no Website'),
          ),
        ],
      ),
    );
  }

  String _getPackageName(String id) {
    switch (id) {
      case 'basic': return 'Cerimónia Simples';
      case 'premium': return 'Cerimónia Premium';
      case 'complete': return 'Pacote Completo';
      default: return '';
    }
  }
}
