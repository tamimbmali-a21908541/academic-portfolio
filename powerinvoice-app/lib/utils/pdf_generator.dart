import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../utils/constants.dart';

class PdfGenerator {
  // Use TextDirection.rtl for Arabic text to render properly
  // The UTF-8 error was in share metadata, not PDF rendering

  static Future<File> generateInvoicePdf(Invoice invoice) async {
    // Load NotoSansArabic font (better Arabic support in PDF)
    final fontData = await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    // ARABIC PAGES (1 or more pages based on content)
    _addInvoicePages(
      pdf: pdf,
      invoice: invoice,
      font: arabicFont,
      language: 'ar',
    );

    // PORTUGUESE PAGES (same number as Arabic)
    _addInvoicePages(
      pdf: pdf,
      invoice: invoice,
      font: arabicFont,
      language: 'pt',
    );

    // ENGLISH PAGES (same number as Arabic)
    _addInvoicePages(
      pdf: pdf,
      invoice: invoice,
      font: arabicFont,
      language: 'en',
    );

    // Save the PDF to a file
    final output = await getTemporaryDirectory();
    // Use simple ASCII filename to avoid encoding issues
    final filename = 'invoice_${invoice.invoiceNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf';
    final file = File('${output.path}/$filename');

    // Save PDF bytes - this is binary data, not text
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes, flush: true);

    // Verify file was written correctly
    if (!await file.exists() || await file.length() == 0) {
      throw Exception('Failed to save PDF file');
    }

    return file;
  }

  /// Add invoice pages for specific language (can be multiple pages based on content)
  static void _addInvoicePages({
    required pw.Document pdf,
    required Invoice invoice,
    required pw.Font font,
    required String language,
  }) {
    final isArabic = language == 'ar';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: font,
        ),
        build: (pw.Context context) {
          return [
            // Company Header
            _buildCompanyHeader(font, isArabic),
            pw.SizedBox(height: 20),

            // Date and Time
            _buildDateTime(font, invoice, language, isArabic),
            pw.SizedBox(height: 25),

            // Invoice Number and Status Row
            _buildInvoiceNumberAndStatus(font, invoice, language, isArabic),
            pw.SizedBox(height: 25),

            // Client Name
            _buildClientName(font, invoice, language, isArabic),
            pw.SizedBox(height: 25),

            // Products Section
            _buildProductsSection(font, invoice, language, isArabic),
            pw.SizedBox(height: 25),

            // Payment Summary
            _buildPaymentSummary(font, invoice, language, isArabic),
            pw.SizedBox(height: 20),

            // Payment History
            if (invoice.payments.isNotEmpty) ...[
              _buildPaymentHistory(font, invoice, language, isArabic),
              pw.SizedBox(height: 20),
            ],

            // Payment Status Note
            if (invoice.remaining > 0)
              _buildPaymentNote(font, invoice, language, isArabic),
          ];
        },
        footer: (pw.Context context) {
          return _buildFooter(font);
        },
      ),
    );
  }

  /// Build company header (centered)
  static pw.Widget _buildCompanyHeader(pw.Font font, bool isArabic) {
    return pw.Center(
      child: pw.Text(
        AppConstants.companyName,
        style: pw.TextStyle(
          font: font,
          fontSize: 28,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  /// Build date and time
  static pw.Widget _buildDateTime(pw.Font font, Invoice invoice, String language, bool isArabic) {
    final dateFormat = DateFormat('d/M/yyyy - HH:mm');
    final formattedDate = dateFormat.format(invoice.createdAt);

    String label;
    pw.TextDirection? textDir;

    switch (language) {
      case 'ar':
        label = 'تاريخ ووقت الإنشاء: $formattedDate';
        textDir = pw.TextDirection.rtl;
        break;
      case 'pt':
        label = 'Data e hora de criação: $formattedDate';
        break;
      case 'en':
        label = 'Date & Time: $formattedDate';
        break;
      default:
        label = 'Date & Time: $formattedDate';
    }

    return pw.Center(
      child: pw.Text(
        label,
        style: pw.TextStyle(
          font: font,
          fontSize: 12,
          color: PdfColors.grey700,
        ),
        textDirection: textDir,
      ),
    );
  }

  /// Build invoice number and status side by side
  static pw.Widget _buildInvoiceNumberAndStatus(pw.Font font, Invoice invoice, String language, bool isArabic) {
    String invoiceLabel;
    pw.TextDirection? textDir;

    switch (language) {
      case 'ar':
        invoiceLabel = 'فاتورة رقم ${invoice.invoiceNumber}';
        textDir = pw.TextDirection.rtl;
        break;
      case 'pt':
        invoiceLabel = 'Fatura nº ${invoice.invoiceNumber}';
        break;
      case 'en':
        invoiceLabel = 'Invoice ${invoice.invoiceNumber}';
        break;
      default:
        invoiceLabel = 'Invoice ${invoice.invoiceNumber}';
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Status box (left side) - RED for unpaid
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey800, width: 2),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            _getStatusText(invoice.status, language, isArabic),
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: invoice.status == InvoiceStatus.unpaid ||
                     invoice.status == InvoiceStatus.partiallyPaid
                  ? PdfColors.red700
                  : PdfColors.green700,
            ),
            textDirection: textDir,
          ),
        ),

        // Invoice number (right side)
        pw.Text(
          invoiceLabel,
          style: pw.TextStyle(
            font: font,
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
          textDirection: textDir,
        ),
      ],
    );
  }

  /// Build client name
  static pw.Widget _buildClientName(pw.Font font, Invoice invoice, String language, bool isArabic) {
    String label;
    pw.TextDirection? textDir;

    switch (language) {
      case 'ar':
        label = 'السيد/ة: ${invoice.clientName} المحترم/ة';
        textDir = pw.TextDirection.rtl;
        break;
      case 'pt':
        label = 'Cliente: ${invoice.clientName}';
        break;
      case 'en':
        label = 'Client: ${invoice.clientName}';
        break;
      default:
        label = 'Client: ${invoice.clientName}';
    }

    return pw.Align(
      alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      child: pw.Text(
        label,
        style: pw.TextStyle(
          font: font,
          fontSize: 13,
        ),
        textDirection: textDir,
      ),
    );
  }

  /// Build products section with table
  static pw.Widget _buildProductsSection(pw.Font font, Invoice invoice, String language, bool isArabic) {
    String sectionTitle;
    List<String> headers;
    pw.TextDirection? textDir;
    pw.Alignment alignment;

    switch (language) {
      case 'ar':
        sectionTitle = 'تفاصيل المنتجات:';
        headers = ['المنتج', 'الكمية', 'السعر', 'الإجمالي'];
        textDir = pw.TextDirection.rtl;
        alignment = pw.Alignment.centerRight;
        break;
      case 'pt':
        sectionTitle = 'Detalhes dos Produtos:';
        headers = ['Produto', 'Quantidade', 'Preço', 'Total'];
        alignment = pw.Alignment.centerLeft;
        break;
      case 'en':
        sectionTitle = 'Product Details:';
        headers = ['Product', 'Quantity', 'Price', 'Total'];
        alignment = pw.Alignment.centerLeft;
        break;
      default:
        sectionTitle = 'Product Details:';
        headers = ['Product', 'Quantity', 'Price', 'Total'];
        alignment = pw.Alignment.centerLeft;
    }

    // Reverse column order for Arabic tables (RTL reading)
    final displayHeaders = isArabic ? headers.reversed.toList() : headers;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Section header
        pw.Align(
          alignment: alignment,
          child: pw.Text(
            sectionTitle,
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: textDir,
          ),
        ),
        pw.SizedBox(height: 10),

        // Products table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey800, width: 1),
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              children: displayHeaders.map((header) => _buildTableHeaderCell(font, header, textDir, isArabic)).toList(),
            ),
            // Product rows
            ...invoice.items.map((item) {
              final productName = item.productName;
              final quantity = item.quantity.toString();
              final price = '${AppConstants.currency}${item.price.toStringAsFixed(2)}';
              final total = '${AppConstants.currency}${item.total.toStringAsFixed(2)}';

              final rowCells = [
                _buildTableDataCell(font, productName, textDir, isArabic, alignRight: true),
                _buildTableDataCell(font, quantity, textDir, isArabic),
                _buildTableDataCell(font, price, textDir, isArabic),
                _buildTableDataCell(font, total, textDir, isArabic),
              ];

              // Reverse cells for Arabic
              final displayCells = isArabic ? rowCells.reversed.toList() : rowCells;
              return pw.TableRow(children: displayCells);
            }),
          ],
        ),
      ],
    );
  }

  /// Build payment summary box
  static pw.Widget _buildPaymentSummary(pw.Font font, Invoice invoice, String language, bool isArabic) {
    String title;
    String totalLabel;
    String paidLabel;
    String remainingLabel;
    pw.TextDirection? textDir;
    pw.Alignment alignment;

    switch (language) {
      case 'ar':
        title = 'ملخص الدفع:';
        totalLabel = 'إجمالي الفاتورة:';
        paidLabel = 'المبلغ المدفوع:';
        remainingLabel = 'المبلغ المتبقي:';
        textDir = pw.TextDirection.rtl;
        alignment = pw.Alignment.centerRight;
        break;
      case 'pt':
        title = 'Resumo do Pagamento:';
        totalLabel = 'Total da Fatura:';
        paidLabel = 'Valor Pago:';
        remainingLabel = 'Valor Restante:';
        alignment = pw.Alignment.centerLeft;
        break;
      case 'en':
        title = 'Payment Summary:';
        totalLabel = 'Invoice Total:';
        paidLabel = 'Amount Paid:';
        remainingLabel = 'Remaining Amount:';
        alignment = pw.Alignment.centerLeft;
        break;
      default:
        title = 'Payment Summary:';
        totalLabel = 'Invoice Total:';
        paidLabel = 'Amount Paid:';
        remainingLabel = 'Remaining Amount:';
        alignment = pw.Alignment.centerLeft;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey800, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Header
          pw.Align(
            alignment: alignment,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: font,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
              textDirection: textDir,
            ),
          ),
          pw.SizedBox(height: 15),

          // Invoice total
          _buildSummaryRow(
            font,
            totalLabel,
            '${AppConstants.currency}${invoice.total.toStringAsFixed(2)}',
            color: PdfColors.black,
            textDir: textDir,
          ),
          pw.SizedBox(height: 8),

          // Amount paid - RED
          _buildSummaryRow(
            font,
            paidLabel,
            '${AppConstants.currency}${invoice.amountPaid.toStringAsFixed(2)}',
            color: PdfColors.red700,
            bold: true,
            textDir: textDir,
          ),
          pw.SizedBox(height: 8),

          // Remaining Amount - RED
          _buildSummaryRow(
            font,
            remainingLabel,
            '${AppConstants.currency}${invoice.remaining.toStringAsFixed(2)}',
            color: PdfColors.red700,
            bold: true,
            textDir: textDir,
          ),
        ],
      ),
    );
  }

  /// Build payment note box
  static pw.Widget _buildPaymentNote(pw.Font font, Invoice invoice, String language, bool isArabic) {
    String noteText;
    pw.TextDirection? textDir;

    switch (language) {
      case 'ar':
        if (invoice.amountPaid == 0) {
          noteText = 'لم يتم سداد أي دفعة لهذه الفاتورة بعد';
        } else {
          noteText = 'تم السداد الجزئي. المتبقي: ${AppConstants.currency}${invoice.remaining.toStringAsFixed(2)}';
        }
        textDir = pw.TextDirection.rtl;
        break;
      case 'pt':
        if (invoice.amountPaid == 0) {
          noteText = 'Nenhum pagamento foi feito para esta fatura ainda';
        } else {
          noteText = 'Pagamento parcial feito. Restante: ${AppConstants.currency}${invoice.remaining.toStringAsFixed(2)}';
        }
        break;
      case 'en':
        if (invoice.amountPaid == 0) {
          noteText = 'No payment has been made for this invoice yet';
        } else {
          noteText = 'Partial payment made. Remaining: ${AppConstants.currency}${invoice.remaining.toStringAsFixed(2)}';
        }
        break;
      default:
        noteText = 'No payment has been made for this invoice yet';
    }

    return pw.Align(
      alignment: pw.Alignment.center,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey600, width: 1.5),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          noteText,
          style: pw.TextStyle(
            font: font,
            fontSize: 11,
            color: PdfColors.grey800,
          ),
          textAlign: pw.TextAlign.center,
          textDirection: textDir,
        ),
      ),
    );
  }

  /// Build payment history table
  static pw.Widget _buildPaymentHistory(pw.Font font, Invoice invoice, String language, bool isArabic) {
    String sectionTitle;
    List<String> headers;
    pw.TextDirection? textDir;
    pw.Alignment alignment;

    switch (language) {
      case 'ar':
        sectionTitle = 'سجل المدفوعات:';
        headers = ['التاريخ والوقت', 'المبلغ المدفوع', 'ملاحظات'];
        textDir = pw.TextDirection.rtl;
        alignment = pw.Alignment.centerRight;
        break;
      case 'pt':
        sectionTitle = 'Histórico de Pagamentos:';
        headers = ['Data e Hora', 'Valor Pago', 'Notas'];
        alignment = pw.Alignment.centerLeft;
        break;
      case 'en':
        sectionTitle = 'Payment History:';
        headers = ['Date & Time', 'Amount Paid', 'Notes'];
        alignment = pw.Alignment.centerLeft;
        break;
      default:
        sectionTitle = 'Payment History:';
        headers = ['Date & Time', 'Amount Paid', 'Notes'];
        alignment = pw.Alignment.centerLeft;
    }

    // Reverse column order for Arabic tables (RTL reading)
    final displayHeaders = isArabic ? headers.reversed.toList() : headers;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Section header
        pw.Align(
          alignment: alignment,
          child: pw.Text(
            sectionTitle,
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: textDir,
          ),
        ),
        pw.SizedBox(height: 10),

        // Payment history table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey800, width: 1),
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              children: displayHeaders.map((header) => _buildTableHeaderCell(font, header, textDir, isArabic)).toList(),
            ),
            // Payment rows
            ...invoice.payments.map((payment) {
              final dateFormat = DateFormat('d/M/yyyy - HH:mm');
              final dateTime = dateFormat.format(payment.paymentDate);
              final amount = '${AppConstants.currency}${payment.amount.toStringAsFixed(2)}';
              final notes = payment.notes ?? (isArabic ? 'دفعة جزئية' : payment.bilingualLabel);

              final rowCells = [
                _buildTableDataCell(font, dateTime, textDir, isArabic),
                _buildTableDataCell(font, amount, textDir, isArabic),
                _buildTableDataCell(font, notes, textDir, isArabic, alignRight: isArabic),
              ];

              // Reverse cells for Arabic
              final displayCells = isArabic ? rowCells.reversed.toList() : rowCells;
              return pw.TableRow(children: displayCells);
            }),
          ],
        ),
      ],
    );
  }

  /// Build footer
  static pw.Widget _buildFooter(pw.Font font) {
    final year = DateTime.now().year;
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            '© $year ${AppConstants.companyName} | Todos os direitos reservados',
            style: pw.TextStyle(
              font: font,
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'Powered by the B Department of Informatics.',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
        pw.Center(
          child: pw.Text(
            'thebinformatica@gmail.com',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods

  static pw.Widget _buildTableHeaderCell(pw.Font font, String text, pw.TextDirection? textDirection, bool isArabic) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.center,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: font,
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
          textDirection: textDirection,
        ),
      ),
    );
  }

  static pw.Widget _buildTableDataCell(
    pw.Font font,
    String text,
    pw.TextDirection? textDirection,
    bool isArabic, {
    bool alignRight = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: (alignRight && isArabic) ? pw.Alignment.centerRight : pw.Alignment.center,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
          ),
          textDirection: textDirection,
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(
    pw.Font font,
    String label,
    String value, {
    PdfColor color = PdfColors.black,
    bool bold = false,
    pw.TextDirection? textDir,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
            color: color,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
          textDirection: textDir,
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
            color: color,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
          textDirection: textDir,
        ),
      ],
    );
  }

  static String _getStatusText(InvoiceStatus status, String language, bool isArabic) {
    switch (language) {
      case 'ar':
        switch (status) {
          case InvoiceStatus.paid:
            return 'مدفوع / PAID';
          case InvoiceStatus.unpaid:
            return 'غير مدفوع / UNPAID';
          case InvoiceStatus.partiallyPaid:
            return 'مدفوع جزئيًا / PARTIALLY PAID';
          case InvoiceStatus.draft:
            return 'مسودة / DRAFT';
          case InvoiceStatus.overdue:
            return 'متأخر / OVERDUE';
          case InvoiceStatus.cancelled:
            return 'ملغى / CANCELLED';
        }
      case 'pt':
        switch (status) {
          case InvoiceStatus.paid:
            return 'PAGO';
          case InvoiceStatus.unpaid:
            return 'NÃO PAGO';
          case InvoiceStatus.partiallyPaid:
            return 'PARCIALMENTE PAGO';
          case InvoiceStatus.draft:
            return 'RASCUNHO';
          case InvoiceStatus.overdue:
            return 'ATRASADO';
          case InvoiceStatus.cancelled:
            return 'CANCELADO';
        }
      case 'en':
        switch (status) {
          case InvoiceStatus.paid:
            return 'PAID';
          case InvoiceStatus.unpaid:
            return 'UNPAID';
          case InvoiceStatus.partiallyPaid:
            return 'PARTIALLY PAID';
          case InvoiceStatus.draft:
            return 'DRAFT';
          case InvoiceStatus.overdue:
            return 'OVERDUE';
          case InvoiceStatus.cancelled:
            return 'CANCELLED';
        }
      default:
        return 'UNPAID';
    }
  }
}
