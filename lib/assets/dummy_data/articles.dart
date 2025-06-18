import '../data_classes/article.dart';

/// Dummy list of articles extracted from Dr. Constanza Castilla’s public
/// Doctoralia profile. These are displayed in the “Artículos” section of the
/// demo app.
final List<Article> dummyArticles = [
  Article(
    id: 'crecimiento-desarrollo',
    title: 'Crecimiento y desarrollo pediátrico',
    excerpt:
        'El crecimiento y desarrollo de un niño es un proceso dinámico que requiere acompañamiento y seguimiento…',
    body: '''
El crecimiento y desarrollo de un niño es un proceso dinámico que requiere acompañamiento y seguimiento. Durante el primer año de vida el bebé pasa de ser totalmente dependiente y con poca actividad, a ser semi independiente y con mucha actividad al año de edad. Durante esta etapa, las visitas al Pediatra deben ser mensuales y en cada una evaluaré el logro del mes y te diré cómo estimular adecuadamente el siguiente. Hablaremos de alimentación, hábito intestinal, sueño, vacunas y responderé preguntas de crianza. El segundo año las visitas son cada dos o tres meses y a partir del tercer año nos veremos cada 4–6 meses hasta los cinco años. El Pediatra es el especialista en niños.
''',
    heroImageUrl: 'lib/assets/images/articles/crecimiento.jpeg',
    publishedAt: DateTime(2025, 6, 14),
    category: ArticleCategory.education,
    tags: ['Pediatría', 'Crecimiento', 'Desarrollo'],
    author: 'Dra. Constanza Castilla Latorre',
  ),
  Article(
    id: 'orientacion-lactancia',
    title: 'Orientación para la lactancia materna',
    excerpt:
        'La lactancia materna es una experiencia maravillosa, sin embargo en ocasiones su inicio puede ser doloroso y angustiante…',
    body: '''
La lactancia materna es una experiencia maravillosa, sin embargo en ocasiones su inicio puede ser doloroso y angustiante para una madre primeriza. Los problemas con la lactancia son una urgencia médica y de la rapidez y efectividad con que se resuelvan va a depender la alimentación de tu hijo. Te invito a participar del taller: "Vive una lactancia feliz" dictado a parejas y si ya tienes problemas como fisuras, grietas o dolor al amamantar, no dudes en solicitar una cita de lactancia llamándonos. Te garantizo darle solución a la situación para que vivas la lactancia como la mejor experiencia de tu vida.
''',
    heroImageUrl: 'lib/assets/images/articles/lactancia.jpeg',
    publishedAt: DateTime(2025, 6, 14),
    category: ArticleCategory.education,
    tags: ['Lactancia', 'Maternidad', 'IBCLC'],
    author: 'Dra. Constanza Castilla Latorre',
  ),
];
