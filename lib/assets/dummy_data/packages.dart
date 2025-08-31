import '../data_classes/product.dart';

class VaccinationProgramRepository {
  List<VaccinationProgram> getPrograms() {
    return [
      VaccinationProgram(
        id: 'vp_baby_standard',
        name: 'Baby Standard',
        commonName: 'Baby Standard',
        description:
            'Programa completo de vacunación para bebés desde los 2 hasta los 18 meses.',
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'programa_baby_standard.jpeg',
        applicableDoctors: ['Pediatría'],
        minAge: 2,
        maxAge: 18,
        specialIndications:
            'Ideal para cumplir con el esquema ampliado de vacunación infantil.',
        includedDoseBundles: [
          '2_meses_baby_standard',
          '3_meses_baby_standard',
          '4_meses_baby_standard',
          '5_meses_baby_standard',
          '6_meses_baby_standard',
          '7_meses_baby_standard',
          '12_meses_baby_standard',
          '13_meses_baby_standard',
          '18_meses_baby_standard',
        ],
      ),
      VaccinationProgram(
        id: 'vp_baby_star',
        name: 'Baby Star',
        commonName: 'Baby Star',
        description:
            'Programa de vacunación premium para bebés desde los 2 hasta los 18 meses con vacunas de última generación.',
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'programa_baby_star.jpeg',
        applicableDoctors: ['Pediatría'],
        minAge: 2,
        maxAge: 18,
        specialIndications:
            'Incluye vacunas del sector privado y de alto espectro como VAXNEUVANCE, Proquad y Pentaxim.',
        includedDoseBundles: [
          '2_meses_baby_star',
          '3_meses_baby_star',
          '4_meses_baby_star',
          '5_meses_baby_star',
          '6_meses_baby_star',
          '7_meses_baby_star',
          '12_meses_baby_star',
          '13_meses_baby_star',
          '18_meses_baby_star',
        ],
      ),
    ];
  }
}
