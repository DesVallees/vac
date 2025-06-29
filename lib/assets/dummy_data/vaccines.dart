import '../data_classes/product.dart';

class ProductRepository {
  List<Product> getProducts() {
    return [
      // Difteria - Tétanos - Tos ferina (DTP)
      Vaccine(
        id: 'v_dtp',
        name: 'DTP',
        commonName: 'Difteria - Tétanos - Tos ferina',
        description:
            'Protección combinada contra Difteria, Tétanos y Tos ferina.',
        price: 40000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/dtp.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 2,
        maxAge: 6,
        manufacturer: 'GENÉRICO',
        dosageInfo: '3 dosis: 2, 4 y 6 meses',
        targetDiseases: 'Difteria, Tétanos y Tos ferina',
        dosesAndBoosters: '3 dosis',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),

      // Haemophilus Influenzae tipo b (Hib)
      Vaccine(
        id: 'v_hib',
        name: 'Hib',
        commonName: 'Haemophilus influenzae tipo b',
        description:
            'Protección contra enfermedades causadas por Haemophilus influenzae tipo b.',
        price: 30000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/hib.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 2,
        maxAge: 6,
        manufacturer: 'GENÉRICO',
        dosageInfo: '3 dosis: 2, 4 y 6 meses',
        targetDiseases: 'Meningitis, neumonía y otras por Hib',
        dosesAndBoosters: '3 dosis',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),

      // Hepatitis B
      Vaccine(
        id: 'v_hepb',
        name: 'Hepatitis B',
        commonName: 'Hepatitis B',
        description: 'Protección contra el virus de la Hepatitis B.',
        price: 25000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/hepatitis_b.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 0,
        maxAge: 12,
        manufacturer: 'GENÉRICO',
        dosageInfo: '3 dosis: nacimiento, 2 y 6 meses',
        targetDiseases: 'Hepatitis B',
        dosesAndBoosters: '3 dosis',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),

      // INFANRIX HEXA
      Vaccine(
        id: 'v_infanrix_hexa',
        name: 'INFANRIX HEXA',
        commonName: 'VACUNA HEXAVALENTE',
        description: 'Vacuna hexavalente para protección integral.',
        price: 130000.0,
        priceAvacunar: 135000.0,
        priceVita: 110000.0,
        priceColsanitas: 114300.0,
        imageUrl: 'lib/assets/images/products/infanrix_hexa.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 0,
        maxAge: 5,
        manufacturer: 'GSK',
        dosageInfo: 'Seguir protocolo de administración',
        targetDiseases:
            'Vacuna diseñada para proteger a tu hij@ contra infecciones.',
        dosesAndBoosters: '3+1',
        specialIndications: 'Bebés prematuros, con indicación médica',
        contraindications: null,
        precautions: null,
      ),
      // PREVENAR 13
      Vaccine(
        id: 'v_prevenar_13',
        name: 'PREVENAR 13',
        commonName: 'CONJUGADA CONTRA NEUMOCOCO 13 SEROTIPOS',
        description: 'Vacuna conjugada para la prevención de neumococo.',
        price: 140000.0,
        priceAvacunar: 149000.0,
        priceVita: null,
        priceColsanitas: 134200.0,
        imageUrl: 'lib/assets/images/products/prevenar_13.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 0,
        maxAge: 5,
        manufacturer: 'PFIZER',
        dosageInfo: 'Seguir protocolo de administración',
        targetDiseases: 'Protege a tu hijo contra la infección neumococo.',
        dosesAndBoosters: 'PAI 2+1 RECOMENDACION 3+1',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      // NIMENRIX
      Vaccine(
        id: 'v_nimenrix',
        name: 'NIMENRIX',
        commonName: 'VACUNA ANTIMENINGOCOCCICA TETRACONJUGADA',
        description: 'Vacuna antimeningocócica tetrajugulada.',
        price: 150000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/nimenrix.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 0,
        maxAge: 18,
        manufacturer: 'PFIZER',
        dosageInfo: 'Seguir protocolo de administración',
        targetDiseases: 'Protege a tu hijo contra la bacteria Neisseria.',
        dosesAndBoosters: '6 sem - 6m 2+1 ; 6m-12m 1+1 ; >12 m 1',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      // INFLUVAC TETRA
      Vaccine(
        id: 'v_influvac',
        name: 'INFLUVAC TETRA',
        commonName: 'VACUNA CUADRIVALENTE CONTRA INFLUENZA',
        description: 'Vacuna cuadrivalente para la prevención de la influenza.',
        price: 160000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/influvac_tetra.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Medicina General'],
        minAge: 6,
        maxAge: 65,
        manufacturer: 'ABBOT',
        dosageInfo: 'Seguir protocolo de administración',
        targetDiseases:
            'Vacuna anual que protege a ti y a tu familia contra la influenza.',
        dosesAndBoosters: '2 dosis + refuerzo anual',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      // PRIORIX
      Vaccine(
        id: 'v_priorix',
        name: 'PRIORIX',
        commonName: 'VACUNA TRIPLE VIRAL',
        description: 'Vacuna triple viral para la protección infantil.',
        price: 120000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/priorix.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 1,
        maxAge: 18,
        manufacturer: 'GSK',
        dosageInfo: 'Seguir protocolo de administración',
        targetDiseases: 'Vacuna que protege contra tres enfermedades virales.',
        dosesAndBoosters: '2 dosis (12 y 18 m)',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      // BOOSTRIX
      Vaccine(
        id: 'v_boostrix',
        name: 'BOOSTRIX (Difteria, Tosferina, Tetános -acelular)',
        commonName: 'BOOSTRIX',
        description:
            'Vacuna combinada para la protección contra difteria, tosferina y tétanos.',
        price: 85000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/boostrix.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 0,
        maxAge: 5,
        manufacturer: 'GSK',
        dosageInfo: '2 dosis, 4 semanas de diferencia',
        targetDiseases: 'Protege contra difteria, tosferina y tétanos.',
        dosesAndBoosters: '2 dosis',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      // FLUARIX
      Vaccine(
        id: 'v_fluarix',
        name: 'FLUARIX',
        commonName: 'FLUARIX',
        description: 'Vacuna contra la influenza (no ofertado).',
        price: 33250.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/fluarix.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Medicina General'],
        minAge: 6,
        maxAge: 65,
        manufacturer: 'Sanofi',
        dosageInfo: 'Una dosis anual',
        targetDiseases: 'Protege contra la influenza.',
        dosesAndBoosters: '1 dosis anual',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      // HAVRIX 720
      Vaccine(
        id: 'v_havrix_720',
        name: 'HAVRIX 720 (Hepatitis A Niños)',
        commonName: 'HAVRIX 720',
        description: 'Vacuna para la prevención de Hepatitis A en niños.',
        price: 140000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/havrix_72.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 1,
        maxAge: 12,
        manufacturer: 'GSK',
        dosageInfo: '2 dosis, 6-12 meses de diferencia',
        targetDiseases: 'Protege contra la hepatitis A.',
        dosesAndBoosters: '2 dosis',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      // Rotarix
      Vaccine(
        id: 'v_rotarix',
        name: 'Rotarix',
        commonName: 'Rotarix',
        description:
            'Vacuna contra el rotavirus para prevenir gastroenteritis severa.',
        price: 90000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/rotarix.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 0,
        maxAge: 12,
        manufacturer: 'GSK',
        dosageInfo: '2 dosis, a los 2 y 4 meses',
        targetDiseases:
            'Protege contra la gastroenteritis severa causada por el rotavirus.',
        dosesAndBoosters: '2 dosis',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      // Menveo y Bexsero
      Vaccine(
        id: 'v_menveo_bexsero',
        name: 'Menveo y Bexsero',
        commonName: 'Menveo y Bexsero',
        description: 'Vacunas combinadas para la prevención de meningitis.',
        price: 150000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/menveo_bexsero.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 0,
        maxAge: 18,
        manufacturer: 'GSK',
        dosageInfo: 'Seguir protocolo de administración',
        targetDiseases: 'Protege contra varios serogrupos de meningococo.',
        dosesAndBoosters: '2 dosis',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      // TETRAXIM
      Vaccine(
        id: 'v_tetraxim',
        name: 'TETRAXIM',
        commonName: 'TETRAXIM',
        description:
            'Vacuna combinada para la protección contra tétanos, difteria y tosferina.',
        price: 100000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/tetraxim.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 0,
        maxAge: 5,
        manufacturer: 'Sanofi',
        dosageInfo: '2 dosis, 4 semanas de diferencia',
        targetDiseases: 'Protege contra tétanos, difteria y tosferina.',
        dosesAndBoosters: '2 dosis',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      // VARICELA
      Vaccine(
        id: 'v_varicela',
        name: 'VARICELA',
        commonName: 'VARICELA',
        description: 'Vacuna para la prevención de la varicela.',
        price: 110000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/varicela.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 1,
        maxAge: 12,
        manufacturer: 'Merck',
        dosageInfo: '1 o 2 dosis según protocolo',
        targetDiseases: 'Protege contra la varicela.',
        dosesAndBoosters: '1-2 dosis',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      Vaccine(
        id: 'v_stamaril',
        name: 'STAMARIL',
        commonName: 'VACUNA CONTRA FIEBRE AMARILLA',
        description:
            'Vacuna de virus vivo atenuado para la prevención de la fiebre amarilla.',
        price: 130000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/stamaril.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Medicina General', 'Pediatría'],
        minAge: 1,
        maxAge: 65,
        manufacturer: 'Sanofi',
        dosageInfo: '1 dosis (12–18 meses)',
        targetDiseases: 'Protección contra la fiebre amarilla',
        dosesAndBoosters: '1 dosis única',
        specialIndications:
            'Requerida para viajar a zonas endémicas y países que la exigen.',
        contraindications:
            'Menores de 9 meses, inmunocomprometidos, alérgicos severos a huevo',
        precautions:
            'Consultar con el médico antes de aplicar en mayores de 60 años',
      ),
      Vaccine(
        id: 'v_flu_trivalente',
        name: 'FLU TRIVALENTE',
        commonName: 'VACUNA TRIVALENTE CONTRA LA INFLUENZA',
        description:
            'Vacuna inactivada que protege contra tres cepas del virus de la influenza.',
        price: 100000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/flu_trivalente.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Medicina General', 'Pediatría'],
        minAge: 0,
        maxAge: 65,
        manufacturer: 'GENÉRICO',
        dosageInfo: '1 o 2 dosis iniciales, luego anual',
        targetDiseases: 'Prevención de la influenza estacional',
        dosesAndBoosters: '1 dosis anual',
        specialIndications:
            'Recomendada especialmente en temporada de influenza y para grupos de riesgo',
        contraindications:
            'Alergia severa al huevo o componentes de la vacuna, antecedentes de síndrome de Guillain-Barré',
        precautions:
            'Consultar al médico si se tiene fiebre o infección activa',
      ),
      Vaccine(
        id: 'v_vaxneuvance',
        name: 'VAXNEUVANCE',
        commonName: 'VACUNA CONTRA NEUMOCOCO CONJUGADA 15 SEROTIPOS',
        description:
            'Protección contra 15 serotipos de enfermedad invasiva por neumococo.',
        price: 230000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/vaxneuvance.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 0,
        maxAge: 65,
        manufacturer: 'MSD',
        dosageInfo:
            '<6m esquema 3+1; 7–12m esquema 2+1; 12m–2a 2 dosis. >2años 1 dosis',
        targetDiseases:
            'Protección contra 15 serotipos de enfermedad invasiva por neumococo.',
        dosesAndBoosters: 'Variable según edad: 3+1, 2+1, 2 dosis, o 1 dosis',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      Vaccine(
        id: 'v_pentaxim',
        name: 'PENTAXIM',
        commonName: 'VACUNA PENTAVALENTE ACELULAR',
        description:
            'Protección contra difteria, tétanos, tos ferina, poliomielitis e infecciones por Hib.',
        price: 185000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/pentaxim.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 2,
        maxAge: 6,
        manufacturer: 'Sanofi',
        dosageInfo: '3 dosis: 2, 4 y 6 meses',
        targetDiseases: 'Difteria, Tétanos, Tos ferina, Poliomielitis, Hib',
        dosesAndBoosters: '3 dosis + 1 refuerzo',
        specialIndications: null,
        contraindications: null,
        precautions: null,
      ),
      Vaccine(
        id: 'v_proquad',
        name: 'PROQUAD',
        commonName: 'VACUNA CUÁDRUPLE VIRAL',
        description:
            'Vacuna combinada contra sarampión, paperas, rubéola y varicela.',
        price: 305000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/proquad.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 1,
        maxAge: 12,
        manufacturer: 'Merck',
        dosageInfo: '2 dosis: 12 y 18 meses',
        targetDiseases: 'Sarampión, paperas, rubéola, varicela',
        dosesAndBoosters: '2 dosis',
        specialIndications: null,
        contraindications: 'Hipersensibilidad a componentes de la vacuna',
        precautions: null,
      ),
      // Rotateq
      Vaccine(
        id: 'v_rotateq',
        name: 'Rotateq',
        commonName: 'Rotateq',
        description:
            'Vacuna oral pentavalente para la prevención de gastroenteritis por rotavirus.',
        price: 95000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/rotateq.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 0,
        maxAge: 8,
        manufacturer: 'Merck',
        dosageInfo: '3 dosis: 2, 4 y 6 meses',
        targetDiseases:
            'Protege contra gastroenteritis severa causada por rotavirus.',
        dosesAndBoosters: '3 dosis',
        specialIndications: null,
        contraindications:
            'No administrar si hay antecedentes de invaginación intestinal.',
        precautions: null,
      ),
      // BEXSERO
      Vaccine(
        id: 'v_bexsero',
        name: 'BEXSERO',
        commonName: 'VACUNA CONTRA MENINGOCOCO B',
        description:
            'Vacuna para la prevención de enfermedades invasivas causadas por Neisseria meningitidis serogrupo B.',
        price: 350000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: 'lib/assets/images/products/bexsero.jpeg',
        category: ProductCategory.vaccine,
        applicableDoctors: ['Pediatría'],
        minAge: 2,
        maxAge: 24,
        manufacturer: 'GSK',
        dosageInfo:
            '2–5 meses: 3 dosis + refuerzo; 6–11 meses: 2 dosis + refuerzo; 12–23 meses: 2 dosis + refuerzo',
        targetDiseases: 'Enfermedad meningocócica invasiva por serogrupo B',
        dosesAndBoosters: 'Esquema varía según edad de inicio',
        specialIndications: 'Niños pequeños, inmunocomprometidos, brotes',
        contraindications: null,
        precautions: null,
      ),
    ];
  }
}
