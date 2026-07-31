import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/url_helper.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  String _selectedPurpose = 'general';
  double _customAmount = 0;
  final _amountController = TextEditingController();

  final List<double> _predefinedAmounts = [10, 25, 50, 100, 250];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Doar no Website',
            onPressed: () {
              UrlHelper.openUrl(context, AppConstants.donateUrl, title: 'Doação - CIL');
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
                  const Icon(Icons.volunteer_activism, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Apoie a CIL',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A sua doação ajuda a manter as atividades da Comunidade Islâmica de Lisboa.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Purpose Selection
            Text(
              'Finalidade da Doação',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPurposeSelector(),
            const SizedBox(height: 24),

            // Amount Selection
            Text(
              'Valor da Doação',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildAmountSelector(),
            const SizedBox(height: 24),

            // Custom Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Outro valor',
                prefixText: '€ ',
                hintText: '0.00',
              ),
              onChanged: (value) {
                setState(() {
                  _customAmount = double.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 24),

            // Info Cards
            _buildInfoSection(),
            const SizedBox(height: 24),

            // Donate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _customAmount > 0 ? () {
                  _showDonationConfirmation();
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.secondary,
                ),
                child: Text(
                  _customAmount > 0 ? 'Doar €${_customAmount.toStringAsFixed(2)}' : 'Selecione um valor',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Alternative Methods
            Center(
              child: TextButton(
                onPressed: () {
                  _showAlternativeMethods();
                },
                child: const Text('Outros métodos de doação'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurposeSelector() {
    final purposes = [
      {'id': 'general', 'name': 'Doação Geral', 'icon': Icons.volunteer_activism},
      {'id': 'zakat', 'name': 'Zakat', 'icon': Icons.balance},
      {'id': 'sadaqah', 'name': 'Sadaqah', 'icon': Icons.favorite},
      {'id': 'building', 'name': 'Fundo de Construção', 'icon': Icons.construction},
      {'id': 'education', 'name': 'Educação', 'icon': Icons.school},
      {'id': 'social', 'name': 'Acção Social', 'icon': Icons.people},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: purposes.length,
      itemBuilder: (context, index) {
        final purpose = purposes[index];
        final isSelected = _selectedPurpose == purpose['id'];

        return InkWell(
          onTap: () {
            setState(() {
              _selectedPurpose = purpose['id'] as String;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  purpose['icon'] as IconData,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  purpose['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _predefinedAmounts.map((amount) {
        final isSelected = _customAmount == amount;

        return ChoiceChip(
          label: Text('€${amount.toInt()}'),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _customAmount = amount;
              _amountController.text = amount.toStringAsFixed(0);
            });
          },
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoCard(
          Icons.security,
          'Seguro',
          'Pagamento seguro através de plataformas certificadas.',
        ),
        const SizedBox(height: 8),
        _buildInfoCard(
          Icons.receipt,
          'Recibo',
          'Receba um recibo por email para efeitos fiscais.',
        ),
        const SizedBox(height: 8),
        _buildInfoCard(
          Icons.repeat,
          'Recorrente',
          'Configure doações mensais automáticas.',
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDonationConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Confirmar Doação'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valor: €${_customAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Finalidade: ${_getPurposeName(_selectedPurpose)}'),
            const SizedBox(height: 16),
            const Text('Será redirecionado para a página de doação no website da CIL.'),
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
              // Redirect to website donation page
              UrlHelper.openUrl(context, AppConstants.donateUrl, title: 'Doação - CIL');
            },
            child: const Text('Continuar no Website'),
          ),
        ],
      ),
    );
  }

  void _showAlternativeMethods() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outros Métodos de Doação',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.account_balance),
              title: Text('Transferência Bancária'),
              subtitle: Text('IBAN: PT50 0035 0000 0000 0000 0000 0'),
            ),
            const ListTile(
              leading: Icon(Icons.phone_android),
              title: Text('MB Way'),
              subtitle: Text('+351 912 345 678'),
            ),
            const ListTile(
              leading: Icon(Icons.storefront),
              title: Text('Presencialmente'),
              subtitle: Text('No secretariado da Mesquita'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPurposeName(String id) {
    switch (id) {
      case 'general': return 'Doação Geral';
      case 'zakat': return 'Zakat';
      case 'sadaqah': return 'Sadaqah';
      case 'building': return 'Fundo de Construção';
      case 'education': return 'Educação';
      case 'social': return 'Acção Social';
      default: return 'Doação';
    }
  }
}
