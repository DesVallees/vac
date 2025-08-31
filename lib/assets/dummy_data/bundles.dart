import '../data_classes/product.dart';

class DoseBundleRepository {
  List<DoseBundle> getBundles() {
    return [
      // Paquete 2 Meses (INFANRIX HEXA + PREVENAR 13 + NIMENRIX + Rotarix)
      DoseBundle(
        id: '2_meses_baby_standard',
        name: 'Paquete 2 Meses',
        commonName: '2 Meses',
        description:
            'Incluye vacunas recomendadas a los 2 meses: Hexavalente (DTP, Polio, Hib, Hep B), Neumococo, Meningococo y Rotavirus.',
        // Suma = 130k + 140k + 150k + 90k = 510k
        // Aplicamos 10% descuento => 459000
        price: 459000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '2meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 2,
        maxAge: 2,
        specialIndications:
            'Aplicar a partir de la 8a semana de vida según protocolo nacional.',
        includedProductIds: ['v_infanrix_hexa', 'v_prevenar_13', 'v_rotarix'],
        targetMilestone: '2 Meses',
      ),
      // Paquete 3 Meses (Menveo y Bexsero)
      DoseBundle(
        id: '3_meses_baby_standard',
        name: 'Paquete 3 Meses',
        commonName: '3 Meses',
        description:
            'Incluye dosis de Menveo y Bexsero recomendada a los 3 meses.',
        price: 150000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '3meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 3,
        maxAge: 3,
        specialIndications:
            'Se sugiere esta dosis como parte del esquema Baby Standard.',
        includedProductIds: ['v_menveo_bexsero'],
        targetMilestone: '3 Meses',
      ),
      // Paquete 4 Meses (mismas vacunas que a los 2 meses, segunda dosis)
      DoseBundle(
        id: '4_meses_baby_standard',
        name: 'Paquete 4 Meses',
        commonName: '4 Meses',
        description:
            'Incluye vacunas recomendadas a los 4 meses: segunda dosis de Hexavalente, Neumococo, Meningococo y Rotavirus.',
        // Mismo costo que el de 2 meses => 459000
        price: 459000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '4meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 4,
        maxAge: 4,
        specialIndications: 'Segunda dosis de cada vacuna según protocolo.',
        includedProductIds: ['v_infanrix_hexa', 'v_prevenar_13', 'v_rotarix'],
        targetMilestone: '4 Meses',
      ),
      // Paquete 5 Meses (Menveo y Bexsero)
      DoseBundle(
        id: '5_meses_baby_standard',
        name: 'Paquete 5 Meses',
        commonName: '5 Meses',
        description: 'Dosis adicional de Menveo y Bexsero según esquema.',
        price: 150000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '5meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 5,
        maxAge: 5,
        specialIndications: 'Segundo refuerzo de Menveo y Bexsero.',
        includedProductIds: ['v_menveo_bexsero'],
        targetMilestone: '5 Meses',
      ),
      // Paquete 6 Meses (tercera de Hexavalente, Neumococo, Meningococo + Influenza)
      DoseBundle(
        id: '6_meses_baby_standard',
        name: 'Paquete 6 Meses',
        commonName: '6 Meses',
        description:
            'Incluye vacunas recomendadas a los 6 meses: tercera dosis de Hexavalente, Neumococo, Meningococo y primera dosis de Influenza.',
        // Suma = 130k + 140k + 150k + 160k = 580k
        // 10% descuento => 522000
        price: 522000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '6meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 6,
        maxAge: 6,
        specialIndications:
            'Incluye la primera dosis de influenza a partir de los 6 meses.',
        includedProductIds: ['v_infanrix_hexa', 'v_prevenar_13', 'v_influvac'],
        targetMilestone: '6 Meses',
      ),
      // Paquete 7 Meses (segunda dosis de Influenza)
      DoseBundle(
        id: '7_meses_baby_standard',
        name: 'Paquete 7 Meses',
        commonName: '7 Meses',
        description:
            'Incluye la segunda dosis de Influenza estacional recomendada alrededor de los 7 meses.',
        price: 160000.0, // o aplica descuento si quieres
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '7meses.jpg',
        applicableDoctors: ['Pediatría', 'Medicina General'],
        minAge: 7,
        maxAge: 7,
        specialIndications:
            'La segunda dosis de Influenza se recomienda 4 semanas después de la primera.',
        includedProductIds: ['v_influvac'],
        targetMilestone: '7 Meses',
      ),
      // Paquete 12 Meses (completo)
      DoseBundle(
        id: '12_meses_baby_standard',
        name: 'Paquete 12 Meses Completo',
        commonName: '12 Meses',
        description: 'Incluye SRP, Varicela, Hepatitis A y Prevenar 13.',
        price: 510000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '12meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 12,
        maxAge: 12,
        specialIndications: 'Cobertura total recomendada al cumplir un año.',
        includedProductIds: [
          'v_priorix',
          'v_varicela',
          'v_havrix_720',
          'v_prevenar_13'
        ],
        targetMilestone: '12 Meses',
      ),
      // Paquete 13 Meses (Menveo y Bexsero)
      DoseBundle(
        id: '13_meses_baby_standard',
        name: 'Paquete 13 Meses',
        commonName: '13 Meses',
        description: 'Tercer refuerzo de Menveo y Bexsero después del año.',
        price: 150000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '13meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 13,
        maxAge: 13,
        specialIndications:
            'Aplicar un mes después del paquete de los 12 meses.',
        includedProductIds: ['v_menveo_bexsero'],
        targetMilestone: '13 Meses',
      ),
      // Paquete 18 Meses
      DoseBundle(
        id: '18_meses_baby_standard',
        name: 'Paquete 18 Meses',
        commonName: '18 Meses',
        description:
            'Incluye refuerzo de Hexavalente, Fiebre Amarilla, Hepatitis A, Influenza trivalente e Influvac.',
        price: 650000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '18meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 18,
        maxAge: 18,
        specialIndications: 'Refuerzos importantes para inmunidad completa.',
        includedProductIds: [
          'v_infanrix_hexa',
          'v_stamaril',
          'v_havrix_720',
          'v_flu_trivalente',
          'v_influvac'
        ],
        targetMilestone: '18 Meses',
      ),

      // ------------------------------------------------------- Baby Star -------------------------------------

      // Paquete Baby Star - 2 Meses
      DoseBundle(
        id: '2_meses_baby_star',
        name: 'Paquete Baby Star 2 Meses',
        commonName: '2 Meses',
        description:
            'Hexavalente, VAXNEUVANCE y Rotateq recomendadas a los 2 meses.',
        price: 700000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '2meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 2,
        maxAge: 2,
        specialIndications: 'Inicio del esquema Baby Star.',
        includedProductIds: ['v_infanrix_hexa', 'v_vaxneuvance', 'v_rotateq'],
        targetMilestone: '2 Meses',
      ),
      // Paquete Baby Star - 3 Meses
      DoseBundle(
        id: '3_meses_baby_star',
        name: 'Paquete Baby Star 3 Meses',
        commonName: '3 Meses',
        description:
            'Incluye Nimenrix y Bexsero como parte del esquema extendido Baby Star.',
        price: 838000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '3meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 3,
        maxAge: 3,
        specialIndications: 'Se recomienda como parte del refuerzo temprano.',
        includedProductIds: ['v_nimenrix', 'v_bexsero'],
        targetMilestone: '3 Meses',
      ),
      // Paquete Baby Star - 4 Meses
      DoseBundle(
        id: '4_meses_baby_star',
        name: 'Paquete Baby Star 4 Meses',
        commonName: '4 Meses',
        description: 'Segunda dosis de Hexavalente, VAXNEUVANCE y Rotateq.',
        price: 700000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '4meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 4,
        maxAge: 4,
        specialIndications: 'Continuación del esquema Baby Star.',
        includedProductIds: ['v_infanrix_hexa', 'v_vaxneuvance', 'v_rotateq'],
        targetMilestone: '4 Meses',
      ),
      // Paquete Baby Star - 5 Meses
      DoseBundle(
        id: '5_meses_baby_star',
        name: 'Paquete Baby Star 5 Meses',
        commonName: '5 Meses',
        description:
            'Dosis adicional de Nimenrix y Bexsero según cronograma Baby Star.',
        price: 838000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '5meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 5,
        maxAge: 5,
        specialIndications:
            'Segundo refuerzo para ampliar protección frente a meningococo y meningitis B.',
        includedProductIds: ['v_nimenrix', 'v_bexsero'],
        targetMilestone: '5 Meses',
      ),
      // Paquete Baby Star - 6 Meses
      DoseBundle(
        id: '6_meses_baby_star',
        name: 'Paquete Baby Star 6 Meses',
        commonName: '6 Meses',
        description:
            'Tercera dosis de Hexavalente, VAXNEUVANCE, Rotateq e Influvac.',
        price: 800000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '6meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 6,
        maxAge: 6,
        specialIndications: 'Incluye primera dosis de influenza.',
        includedProductIds: [
          'v_infanrix_hexa',
          'v_vaxneuvance',
          'v_rotateq',
          'v_influvac'
        ],
        targetMilestone: '6 Meses',
      ),
      // Paquete Baby Star - 7 Meses
      DoseBundle(
        id: '7_meses_baby_star',
        name: 'Paquete Baby Star 7 Meses',
        commonName: '7 Meses',
        description:
            'Segunda dosis de Influvac como parte del esquema Baby Star.',
        price: 65000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '7meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 7,
        maxAge: 7,
        specialIndications:
            'Segunda aplicación de la vacuna contra la influenza.',
        includedProductIds: ['v_influvac'],
        targetMilestone: '7 Meses',
      ),
      // Paquete Baby Star - 12 Meses
      DoseBundle(
        id: '12_meses_baby_star',
        name: 'Paquete Baby Star 12 Meses',
        commonName: '12 Meses',
        description: 'Incluye Proquad, VAXNEUVANCE y Havrix 720.',
        price: 675000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '12meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 12,
        maxAge: 12,
        specialIndications: 'Cobertura importante al año de vida.',
        includedProductIds: ['v_proquad', 'v_vaxneuvance', 'v_havrix_720'],
        targetMilestone: '12 Meses',
      ),
      // Paquete Baby Star - 13 Meses
      DoseBundle(
        id: '13_meses_baby_star',
        name: 'Paquete Baby Star 13 Meses',
        commonName: '13 Meses',
        description:
            'Dosis final de Nimenrix y Bexsero después del primer año.',
        price: 838000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '13meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 13,
        maxAge: 13,
        specialIndications:
            'Finalización del esquema meningocócico y meningitis B.',
        includedProductIds: ['v_nimenrix', 'v_bexsero'],
        targetMilestone: '13 Meses',
      ),
      // Paquete Baby Star - 18 Meses
      DoseBundle(
        id: '18_meses_baby_star',
        name: 'Paquete Baby Star 18 Meses',
        commonName: '18 Meses',
        description: 'Pentaxim, Stamaril, Havrix 720 y refuerzo de Proquad.',
        price: 655000.0,
        priceAvacunar: null,
        priceVita: null,
        priceColsanitas: null,
        imageUrl: '18meses.jpg',
        applicableDoctors: ['Pediatría'],
        minAge: 18,
        maxAge: 18,
        specialIndications: 'Refuerzos esenciales del esquema Baby Star.',
        includedProductIds: [
          'v_pentaxim',
          'v_stamaril',
          'v_havrix_720',
          'v_proquad'
        ],
        targetMilestone: '18 Meses',
      ),
    ];
  }
}
