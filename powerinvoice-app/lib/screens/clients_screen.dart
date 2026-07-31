import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../models/client.dart';
import '../widgets/client_avatar.dart';
import '../forms/client_form.dart';

/// Clients Screen - Shows list of clients
class ClientsScreen extends StatefulWidget {
  final List<Client> clients;
  final Function(Client) onAdd;
  final Function(Client) onUpdate;
  final Function(String) onDelete;

  const ClientsScreen({
    super.key,
    required this.clients,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Client> get _filteredClients {
    if (_searchQuery.isEmpty) {
      return widget.clients;
    }
    return widget.clients.where((client) {
      final searchLower = _searchQuery.toLowerCase();
      return client.name.toLowerCase().contains(searchLower) ||
          (client.email?.toLowerCase().contains(searchLower) ?? false) ||
          (client.phone?.toLowerCase().contains(searchLower) ?? false) ||
          (client.companyName?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addClient() {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        onSave: (client) {
          widget.onAdd(client);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Client "${client.name}" added successfully'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        },
      ),
    );
  }

  void _editClient(Client client) {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        client: client,
        onSave: (updatedClient) {
          widget.onUpdate(updatedClient);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Client "${updatedClient.name}" updated successfully'),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
        },
      ),
    );
  }

  void _deleteClient(Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete "${client.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(client.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Client "${client.name}" deleted'),
                  backgroundColor: AppColors.errorRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _importFromContacts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import from Contacts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This feature will allow you to:'),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.successGreen, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Access your phone contacts')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.successGreen, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Select multiple contacts')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.successGreen, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Import them as clients')),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Note: Requires contacts permission',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming soon! For now, add clients manually.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.warningOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_contacts),
            tooltip: 'Import from contacts',
            onPressed: _importFromContacts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Client list or empty state
          Expanded(
            child: _filteredClients.isEmpty
                ? _buildEmptyState()
                : _buildClientList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClient,
        tooltip: 'Add Client',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.textGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No clients yet' : 'No clients found',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Add your first client to get started'
                  : 'Try a different search term',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _addClient,
                icon: const Icon(Icons.add),
                label: const Text('Add Client'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              _showClientDetails(client);
            },
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  // Client avatar
                  ClientAvatar(name: client.name),
                  const SizedBox(width: 16),

                  // Client info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite,
                          ),
                        ),
                        if (client.companyName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            client.companyName!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                        if (client.email != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.email,
                                size: 14,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  client.email!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textGrey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (client.phone != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 14,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                client.phone!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Menu button
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: AppColors.textGrey,
                    onPressed: () {
                      _showClientMenu(client);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showClientDetails(Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(client.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (client.companyName != null)
                _DetailRow(label: 'Company', value: client.companyName!),
              if (client.email != null)
                _DetailRow(label: 'Email', value: client.email!),
              if (client.phone != null)
                _DetailRow(label: 'Phone', value: client.phone!),
              if (client.address != null)
                _DetailRow(label: 'Address', value: client.address!),
              if (client.taxNumber != null)
                _DetailRow(label: 'Tax Number', value: client.taxNumber!),
              if (client.notes != null)
                _DetailRow(label: 'Notes', value: client.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editClient(client);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClientMenu(Client client) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primaryBlue),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editClient(client);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: AppColors.successGreen),
              title: const Text('View Invoices'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invoice filtering coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.errorRed),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteClient(client);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }
}
