import '../constants/app_constants.dart';

/// Event Item Model
class EventItem {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? endDate;
  final String time;
  final String? endTime;
  final String location;
  final String imageUrl;
  final String category;
  final bool isRecurring;
  final String? recurrenceRule;
  final bool requiresRegistration;
  final String? registrationUrl;
  final int? maxAttendees;
  final int? currentAttendees;
  final double? price;
  final bool isFree;
  final String webUrl;

  EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.endDate,
    required this.time,
    this.endTime,
    required this.location,
    required this.imageUrl,
    required this.category,
    this.isRecurring = false,
    this.recurrenceRule,
    this.requiresRegistration = false,
    this.registrationUrl,
    this.maxAttendees,
    this.currentAttendees,
    this.price,
    this.isFree = true,
    this.webUrl = '',
  });

  factory EventItem.fromJson(Map<String, dynamic> json, [String? docId]) {
    // Handle date parsing from various formats
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    return EventItem(
      id: docId ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: parseDate(json['date']),
      endDate: json['endDate'] != null ? parseDate(json['endDate']) : null,
      time: json['time'] ?? '',
      endTime: json['endTime'],
      location: json['location'] ?? 'Mesquita Central de Lisboa',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'Geral',
      isRecurring: json['isRecurring'] ?? false,
      recurrenceRule: json['recurrenceRule'],
      requiresRegistration: json['requiresRegistration'] ?? false,
      registrationUrl: json['registrationUrl'],
      maxAttendees: json['maxAttendees'],
      currentAttendees: json['currentAttendees'],
      price: json['price']?.toDouble(),
      isFree: json['isFree'] ?? true,
      webUrl: json['webUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'time': time,
      'endTime': endTime,
      'location': location,
      'imageUrl': imageUrl,
      'category': category,
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
      'requiresRegistration': requiresRegistration,
      'registrationUrl': registrationUrl,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'price': price,
      'isFree': isFree,
      'webUrl': webUrl,
    };
  }

  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  bool get isPast => date.isBefore(DateTime.now());
  bool get hasAvailableSpots => maxAttendees == null || (currentAttendees ?? 0) < maxAttendees!;
}

/// Events Service
class EventsService {
  static const String eventsPageUrl = '${AppConstants.websiteUrl}/events-1';

  /// Get all events
  Future<List<EventItem>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _getSampleEvents();
  }

  /// Get upcoming events
  Future<List<EventItem>> getUpcomingEvents() async {
    final allEvents = await getEvents();
    return allEvents.where((e) => e.isUpcoming).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get events for a specific date
  Future<List<EventItem>> getEventsForDate(DateTime date) async {
    final allEvents = await getEvents();
    return allEvents.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
    }).toList();
  }

  /// Get events by category
  Future<List<EventItem>> getEventsByCategory(String category) async {
    final allEvents = await getEvents();
    return allEvents.where((e) => e.category == category).toList();
  }

  /// Get event by ID
  Future<EventItem?> getEventById(String id) async {
    final allEvents = await getEvents();
    try {
      return allEvents.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Sample events data
  List<EventItem> _getSampleEvents() {
    final now = DateTime.now();
    return [
      EventItem(
        id: '1',
        title: 'Oração de Sexta-feira (Jummah)',
        description: '''
A oração congregacional de sexta-feira é realizada todas as semanas na Mesquita Central de Lisboa.

A khutba (sermão) começa às 13:00, seguida da oração.

Todos os muçulmanos são convidados a participar.
        ''',
        date: _getNextFriday(now),
        time: '13:00',
        endTime: '14:00',
        location: 'Mesquita Central de Lisboa - Sala de Oração Principal',
        imageUrl: 'https://static.wixstatic.com/media/99b369_d881c5966b25444fb7319ba6f7748424~mv2.jpg',
        category: 'Oração',
        isRecurring: true,
        recurrenceRule: 'FREQ=WEEKLY;BYDAY=FR',
        webUrl: eventsPageUrl,
      ),
      EventItem(
        id: '2',
        title: 'Aula de Alcorão para Crianças',
        description: '''
Aulas de Alcorão para crianças dos 6 aos 12 anos.

Programa:
- Leitura do Alcorão
- Memorização de suras curtas
- Histórias dos Profetas
- Valores islâmicos

Inscrições no secretariado.
        ''',
        date: _getNextSaturday(now),
        time: '10:00',
        endTime: '12:00',
        location: 'Mesquita Central de Lisboa - Sala de Ensino',
        imageUrl: 'https://static.wixstatic.com/media/99b369_080be0f5e38849c3917013e08f3cd044~mv2.png',
        category: 'Educação',
        isRecurring: true,
        recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA',
        requiresRegistration: true,
        webUrl: 'https://www.comunidadeislamica.pt/educacao',
      ),
      EventItem(
        id: '3',
        title: 'Jantar de Iftar Comunitário',
        description: '''
Durante o Ramadão, a CIL organiza jantares de iftar comunitários todas as noites.

O iftar é servido após a oração do Maghrib.

Entrada livre - Contribuições são bem-vindas.

Venha partilhar este momento especial connosco!
        ''',
        date: now.add(const Duration(days: 30)),
        time: 'Após Maghrib',
        location: 'Mesquita Central de Lisboa - Refeitório',
        imageUrl: 'https://static.wixstatic.com/media/1fdabb_361ad302bc73445b8e834d0446ece56f~mv2.png',
        category: 'Ramadão',
        isFree: true,
        webUrl: eventsPageUrl,
      ),
      EventItem(
        id: '4',
        title: 'Conferência: Islão e Diálogo Inter-religioso',
        description: '''
Conferência sobre o papel do Islão no diálogo inter-religioso em Portugal.

Oradores:
- Sheikh Ahmed (CIL)
- Padre João Silva
- Rabino David Levy

Seguida de debate e perguntas.
        ''',
        date: now.add(const Duration(days: 14)),
        time: '18:00',
        endTime: '20:00',
        location: 'Mesquita Central de Lisboa - Salão Nobre',
        imageUrl: 'https://static.wixstatic.com/media/1fdabb_79a4846e8fc046378477397bbb23b8ad~mv2.jpg',
        category: 'Conferência',
        requiresRegistration: true,
        maxAttendees: 200,
        currentAttendees: 85,
        isFree: true,
        webUrl: eventsPageUrl,
      ),
      EventItem(
        id: '5',
        title: 'Torneio de Futsal',
        description: '''
Torneio de futsal organizado pela CIL.

Categorias:
- Sub-14
- Sub-18
- Seniores

Prémios para os vencedores!

Inscrições de equipas: desporto@cil.org.pt
        ''',
        date: now.add(const Duration(days: 21)),
        time: '09:00',
        endTime: '18:00',
        location: 'Mesquita Central de Lisboa - Pavilhão Desportivo',
        imageUrl: 'https://static.wixstatic.com/media/1fdabb_79a4846e8fc046378477397bbb23b8ad~mv2.jpg',
        category: 'Desporto',
        requiresRegistration: true,
        price: 20.0,
        isFree: false,
        webUrl: 'https://www.comunidadeislamica.pt/desporto',
      ),
      EventItem(
        id: '6',
        title: 'Workshop: Caligrafia Árabe',
        description: '''
Workshop de introdução à caligrafia árabe.

Aprenda os fundamentos da bela arte da caligrafia islâmica.

Material incluído.
Nível: Iniciantes

Vagas limitadas!
        ''',
        date: now.add(const Duration(days: 7)),
        time: '15:00',
        endTime: '17:00',
        location: 'Mesquita Central de Lisboa - Sala de Artes',
        imageUrl: 'https://static.wixstatic.com/media/99b369_080be0f5e38849c3917013e08f3cd044~mv2.png',
        category: 'Cultura',
        requiresRegistration: true,
        maxAttendees: 20,
        currentAttendees: 12,
        price: 15.0,
        isFree: false,
        webUrl: eventsPageUrl,
      ),
    ];
  }

  DateTime _getNextFriday(DateTime from) {
    int daysUntilFriday = DateTime.friday - from.weekday;
    if (daysUntilFriday <= 0) daysUntilFriday += 7;
    return from.add(Duration(days: daysUntilFriday));
  }

  DateTime _getNextSaturday(DateTime from) {
    int daysUntilSaturday = DateTime.saturday - from.weekday;
    if (daysUntilSaturday <= 0) daysUntilSaturday += 7;
    return from.add(Duration(days: daysUntilSaturday));
  }
}
