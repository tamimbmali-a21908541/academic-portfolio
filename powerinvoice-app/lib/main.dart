import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/colors.dart';
import 'utils/constants.dart';
import 'models/client.dart';
import 'models/product.dart';
import 'models/invoice.dart';
import 'screens/dashboard_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/invoices_screen.dart';
import 'screens/products_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/activation_screen.dart';
import 'services/app_protection.dart';
import 'services/storage_service.dart';

void main() {
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const PowerInvoiceApp());
}

class PowerInvoiceApp extends StatefulWidget {
  const PowerInvoiceApp({super.key});

  @override
  State<PowerInvoiceApp> createState() => _PowerInvoiceAppState();
}

class _PowerInvoiceAppState extends State<PowerInvoiceApp> {
  bool _isActivated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkActivation();
  }

  Future<void> _checkActivation() async {
    final activated = await AppProtection.isActivated();
    setState(() {
      _isActivated = activated;
      _isLoading = false;
    });
  }

  void _onActivated() {
    setState(() {
      _isActivated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Color scheme
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.successGreen,
          surface: AppColors.surfaceDark,
          error: AppColors.errorRed,
        ),

        // Scaffold background
        scaffoldBackgroundColor: AppColors.backgroundDark,

        // AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textWhite,
          ),
          iconTheme: IconThemeData(color: AppColors.textWhite),
        ),

        // Card theme
        cardTheme: CardTheme(
          color: AppColors.surfaceDark,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: AppColors.textGrey),
        ),

        // Floating action button theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
        ),

        // Bottom navigation bar theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textGrey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),

        // Text theme
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textWhite),
          bodyMedium: TextStyle(color: AppColors.textWhite),
          bodySmall: TextStyle(color: AppColors.textGrey),
          titleLarge: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: TextStyle(color: AppColors.textGrey),
        ),
      ),
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isActivated
              ? const MainScreen()
              : ActivationScreen(onActivated: _onActivated),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  // Shared data state - all screens access the same data
  final List<Client> _clients = [];
  final List<Product> _products = [];
  final List<Invoice> _invoices = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load all data from persistent storage
  Future<void> _loadData() async {
    try {
      final clients = await StorageService.loadClients();
      final products = await StorageService.loadProducts();
      final invoices = await StorageService.loadInvoices();

      setState(() {
        _clients.clear();
        _clients.addAll(clients);
        _products.clear();
        _products.addAll(products);
        _invoices.clear();
        _invoices.addAll(invoices);
        _isLoading = false;
      });

      print('Data loaded: ${clients.length} clients, ${products.length} products, ${invoices.length} invoices');
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Callbacks for updating shared data
  void _addClient(Client client) {
    setState(() {
      _clients.add(client);
    });
    StorageService.saveClients(_clients);
  }

  void _updateClient(Client updatedClient) {
    setState(() {
      final index = _clients.indexWhere((c) => c.id == updatedClient.id);
      if (index != -1) {
        _clients[index] = updatedClient;
      }
    });
    StorageService.saveClients(_clients);
  }

  void _deleteClient(String clientId) {
    setState(() {
      _clients.removeWhere((c) => c.id == clientId);
    });
    StorageService.saveClients(_clients);
  }

  void _addProduct(Product product) {
    setState(() {
      _products.add(product);
    });
    StorageService.saveProducts(_products);
  }

  void _updateProduct(Product updatedProduct) {
    setState(() {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
    });
    StorageService.saveProducts(_products);
  }

  void _deleteProduct(String productId) {
    setState(() {
      _products.removeWhere((p) => p.id == productId);
    });
    StorageService.saveProducts(_products);
  }

  void _addInvoice(Invoice invoice) {
    setState(() {
      _invoices.add(invoice);
    });
    StorageService.saveInvoices(_invoices);
  }

  void _updateInvoice(Invoice updatedInvoice) {
    setState(() {
      final index = _invoices.indexWhere((i) => i.id == updatedInvoice.id);
      if (index != -1) {
        _invoices[index] = updatedInvoice;
      }
    });
    StorageService.saveInvoices(_invoices);
  }

  void _deleteInvoice(String invoiceId) {
    setState(() {
      _invoices.removeWhere((i) => i.id == invoiceId);
    });
    StorageService.saveInvoices(_invoices);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is being loaded
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading your data...',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    final List<Widget> screens = [
      DashboardScreen(invoices: _invoices, clients: _clients),
      ClientsScreen(
        clients: _clients,
        onAdd: _addClient,
        onUpdate: _updateClient,
        onDelete: _deleteClient,
      ),
      InvoicesScreen(
        invoices: _invoices,
        clients: _clients,
        products: _products,
        onAdd: _addInvoice,
        onUpdate: _updateInvoice,
        onDelete: _deleteInvoice,
      ),
      ProductsScreen(
        products: _products,
        onAdd: _addProduct,
        onUpdate: _updateProduct,
        onDelete: _deleteProduct,
      ),
      ArchiveScreen(invoices: _invoices),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Archive',
          ),
        ],
      ),
    );
  }
}
