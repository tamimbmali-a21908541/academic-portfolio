import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../models/invoice.dart';

/// Storage Service - Persists all app data using SharedPreferences
class StorageService {
  static const String _clientsKey = 'clients';
  static const String _productsKey = 'products';
  static const String _invoicesKey = 'invoices';

  /// Save clients to persistent storage
  static Future<void> saveClients(List<Client> clients) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = clients.map((client) => client.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_clientsKey, jsonString);
      print('Saved ${clients.length} clients');
    } catch (e) {
      print('Error saving clients: $e');
    }
  }

  /// Load clients from persistent storage
  static Future<List<Client>> loadClients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_clientsKey);
      if (jsonString == null || jsonString.isEmpty) {
        print('No clients found in storage');
        return [];
      }
      final jsonList = jsonDecode(jsonString) as List;
      final clients = jsonList.map((json) => Client.fromJson(json)).toList();
      print('Loaded ${clients.length} clients');
      return clients;
    } catch (e) {
      print('Error loading clients: $e');
      return [];
    }
  }

  /// Save products to persistent storage
  static Future<void> saveProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((product) => product.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_productsKey, jsonString);
      print('Saved ${products.length} products');
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  /// Load products from persistent storage
  static Future<List<Product>> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_productsKey);
      if (jsonString == null || jsonString.isEmpty) {
        print('No products found in storage');
        return [];
      }
      final jsonList = jsonDecode(jsonString) as List;
      final products = jsonList.map((json) => Product.fromJson(json)).toList();
      print('Loaded ${products.length} products');
      return products;
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }

  /// Save invoices to persistent storage
  static Future<void> saveInvoices(List<Invoice> invoices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = invoices.map((invoice) => invoice.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_invoicesKey, jsonString);
      print('Saved ${invoices.length} invoices');
    } catch (e) {
      print('Error saving invoices: $e');
    }
  }

  /// Load invoices from persistent storage
  static Future<List<Invoice>> loadInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_invoicesKey);
      if (jsonString == null || jsonString.isEmpty) {
        print('No invoices found in storage');
        return [];
      }
      final jsonList = jsonDecode(jsonString) as List;
      final invoices = jsonList.map((json) => Invoice.fromJson(json)).toList();
      print('Loaded ${invoices.length} invoices');
      return invoices;
    } catch (e) {
      print('Error loading invoices: $e');
      return [];
    }
  }

  /// Clear all data (for testing/reset)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_clientsKey);
      await prefs.remove(_productsKey);
      await prefs.remove(_invoicesKey);
      print('All data cleared');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  /// Get storage stats
  static Future<Map<String, int>> getStorageStats() async {
    try {
      final clients = await loadClients();
      final products = await loadProducts();
      final invoices = await loadInvoices();

      return {
        'clients': clients.length,
        'products': products.length,
        'invoices': invoices.length,
      };
    } catch (e) {
      print('Error getting storage stats: $e');
      return {
        'clients': 0,
        'products': 0,
        'invoices': 0,
      };
    }
  }
}
