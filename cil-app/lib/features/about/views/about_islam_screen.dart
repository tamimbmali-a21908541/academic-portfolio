import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AboutIslamScreen extends StatelessWidget {
  const AboutIslamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o Islão'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            _buildSection(
              context,
              icon: Icons.auto_awesome,
              title: 'O que é o Islão?',
              content: '''O Islão é uma religião monoteísta que surgiu no século VII na Península Arábica. A palavra "Islão" significa "submissão à vontade de Deus" (Allah em árabe).

Os seguidores do Islão são chamados de muçulmanos, e a sua fé baseia-se na crença de que existe apenas um Deus, e que Maomé é o Seu último mensageiro.''',
            ),

            // Five Pillars
            _buildSection(
              context,
              icon: Icons.account_balance,
              title: 'Os Cinco Pilares do Islão',
              content: '''Os Cinco Pilares são as práticas fundamentais do Islão:

1. **Shahada (Testemunho de Fé)**
   A declaração de que não há outro deus senão Allah, e que Maomé é Seu mensageiro.

2. **Salat (Oração)**
   Os muçulmanos rezam cinco vezes ao dia, virados para Meca.

3. **Zakat (Caridade)**
   Dar uma porção da riqueza aos necessitados.

4. **Sawm (Jejum)**
   Jejuar durante o mês sagrado do Ramadão.

5. **Hajj (Peregrinação)**
   Realizar pelo menos uma vez na vida a peregrinação a Meca.''',
            ),

            // Holy Book
            _buildSection(
              context,
              icon: Icons.menu_book,
              title: 'O Alcorão',
              content: '''O Alcorão (ou Quran) é o livro sagrado do Islão. Os muçulmanos acreditam que é a palavra de Deus, revelada ao Profeta Maomé pelo anjo Gabriel ao longo de 23 anos.

O Alcorão está dividido em 114 capítulos (suras) e contém orientações para todos os aspetos da vida, incluindo:
• Crenças e práticas religiosas
• Leis e ética
• Família e sociedade
• Justiça e compaixão''',
            ),

            // Prophet
            _buildSection(
              context,
              icon: Icons.person,
              title: 'O Profeta Maomé',
              content: '''Maomé (570-632 d.C.) é considerado o último profeta do Islão. Nasceu em Meca e recebeu as primeiras revelações divinas aos 40 anos.

Os muçulmanos respeitam profundamente Maomé e seguem o seu exemplo (Sunnah) através dos Hadith, que são registos das suas palavras e ações.''',
            ),

            // Values
            _buildSection(
              context,
              icon: Icons.favorite,
              title: 'Valores Islâmicos',
              content: '''O Islão promove valores universais como:

• **Paz** - "Islão" vem da raiz "salam" (paz)
• **Compaixão** - Ajudar os necessitados
• **Justiça** - Tratar todos com equidade
• **Conhecimento** - Buscar o saber é um dever
• **Respeito** - Pelos pais, idosos e comunidade
• **Família** - Base da sociedade
• **Honestidade** - Em todas as relações''',
            ),

            // Islam in Portugal
            _buildSection(
              context,
              icon: Icons.location_on,
              title: 'O Islão em Portugal',
              content: '''A presença islâmica em Portugal remonta ao século VIII, quando os mouros governaram grande parte da Península Ibérica durante cerca de 500 anos.

Hoje, Portugal é lar de uma comunidade muçulmana diversificada, com pessoas de várias origens, incluindo:
• Moçambique
• Guiné-Bissau
• Índia e Paquistão
• Bangladesh
• Países árabes

A Mesquita Central de Lisboa, inaugurada em 1985, é o principal centro islâmico do país.''',
            ),

            const SizedBox(height: 24),

            // Contact for more info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info, color: AppColors.primary, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Quer saber mais?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A CIL oferece visitas guiadas e sessões de esclarecimento sobre o Islão. Contacte-nos para mais informações.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
