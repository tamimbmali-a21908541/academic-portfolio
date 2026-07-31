import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/url_helper.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tornar-se Associado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Ver no Website',
            onPressed: () {
              UrlHelper.openUrl(context, AppConstants.membershipUrl, title: 'Adesão - CIL');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.card_membership, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Junte-se à CIL',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Torne-se associado e apoie a nossa comunidade.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Benefits Section
            Text(
              'Benefícios de Associado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitsList(context),
            const SizedBox(height: 24),

            // Membership Types
            Text(
              'Tipos de Associação',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMembershipTypes(context),
            const SizedBox(height: 24),

            // Requirements
            Text(
              'Requisitos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildRequirements(context),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showApplicationForm(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Pedir Adesão'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  UrlHelper.openUrl(context, AppConstants.membershipUrl, title: 'Adesão - CIL');
                },
                icon: const Icon(Icons.open_in_browser, size: 18),
                label: const Text('Aderir via Website'),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Ou visite o secretariado da Mesquita Central',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    final benefits = [
      {'icon': Icons.percent, 'title': 'Descontos', 'desc': 'Descontos em cursos e eventos'},
      {'icon': Icons.event, 'title': 'Eventos Exclusivos', 'desc': 'Acesso a eventos só para associados'},
      {'icon': Icons.how_to_vote, 'title': 'Voto', 'desc': 'Direito a voto nas assembleias'},
      {'icon': Icons.notifications, 'title': 'Informações', 'desc': 'Receba novidades em primeira mão'},
      {'icon': Icons.sports_basketball, 'title': 'Pavilhão', 'desc': 'Preços reduzidos no pavilhão'},
      {'icon': Icons.restaurant, 'title': 'Restaurante', 'desc': 'Desconto no restaurante'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(benefit['icon'] as IconData, color: AppColors.primary, size: 20),
            ),
            title: Text(benefit['title'] as String),
            subtitle: Text(benefit['desc'] as String),
          ),
        );
      },
    );
  }

  Widget _buildMembershipTypes(BuildContext context) {
    final types = [
      {
        'name': 'Associado Individual',
        'price': '30€/ano',
        'description': 'Para indivíduos maiores de 18 anos',
        'color': AppColors.primary,
      },
      {
        'name': 'Associado Familiar',
        'price': '50€/ano',
        'description': 'Para famílias (casal + filhos)',
        'color': AppColors.secondary,
      },
      {
        'name': 'Associado Estudante',
        'price': '15€/ano',
        'description': 'Para estudantes com comprovativo',
        'color': AppColors.info,
      },
      {
        'name': 'Associado Sénior',
        'price': '20€/ano',
        'description': 'Para maiores de 65 anos',
        'color': AppColors.accent,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (type['color'] as Color).withOpacity(0.3)),
            color: (type['color'] as Color).withOpacity(0.05),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: type['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: type['color'] as Color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type['price'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequirements(BuildContext context) {
    final requirements = [
      'Documento de identificação válido',
      'Comprovativo de morada',
      'Fotografia tipo passe',
      'Pagamento da quota anual',
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
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 12),
                  Text(req),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showApplicationForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Formulário de Adesão',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome Completo'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Morada'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Código Postal'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Data de Nascimento'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Show confirmation dialog to redirect to website
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Submeter Pedido'),
                        content: const Text(
                          'Para completar o seu pedido de adesão, será redirecionado para o formulário oficial no website da CIL.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              UrlHelper.openUrl(context, AppConstants.membershipUrl, title: 'Adesão - CIL');
                            },
                            child: const Text('Continuar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Submeter Pedido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
