import '../models/pharmacy_product_model.dart';

class PharmacyData {
  static const List<String> categories = [
    'All',
    'Pain Relief',
    'Cough & Cold',
    'Antibiotics',
    'Vitamins',
    'First Aid',
    'Personal Care',
    'Others',
  ];

  static List<PharmacyProduct> get allProducts => [
    // Pain Relief
    PharmacyProduct(
      id: '1',
      name: 'Paracetamol (Biogesic)',
      localImagePath: 'lib/Images/Paracetamol.png',
      price: 5.99,
      stock: 100,
      stockStatus: 'In Stock',
      description: 'Pain relief and fever reducer. 500mg tablets.',
      category: 'Pain Relief',
    ),
    PharmacyProduct(
      id: '2',
      name: 'Ibuprofen (Advil)',
      localImagePath: 'lib/Images/Ibuprofen.png',
      price: 7.50,
      stock: 80,
      stockStatus: 'In Stock',
      description: 'Anti-inflammatory pain reliever. 200mg capsules.',
      category: 'Pain Relief',
    ),
    PharmacyProduct(
      id: '3',
      name: 'Mefenamic Acid (Ponstan)',
      localImagePath: 'lib/Images/mefenamic.png',
      price: 8.25,
      stock: 60,
      stockStatus: 'In Stock',
      description: 'For menstrual pain and muscle aches. 500mg tablets.',
      category: 'Pain Relief',
    ),
    PharmacyProduct(
      id: '4',
      name: 'Aspirin',
      localImagePath: 'lib/Images/aspirin.png',
      price: 6.00,
      stock: 90,
      stockStatus: 'In Stock',
      description: 'Pain reliever and blood thinner. 325mg tablets.',
      category: 'Pain Relief',
    ),
    
    // Cough & Cold
    PharmacyProduct(
      id: '5',
      name: 'Neozep',
      localImagePath: 'lib/Images/neozep.png',
      price: 6.50,
      stock: 75,
      stockStatus: 'In Stock',
      description: 'Relief for colds and flu symptoms. Non-drowsy formula.',
      category: 'Cough & Cold',
    ),
    PharmacyProduct(
      id: '6',
      name: 'Bioflu',
      localImagePath: 'lib/Images/bioflu.png',
      price: 7.00,
      stock: 70,
      stockStatus: 'In Stock',
      description: 'Complete relief for flu and body pain.',
      category: 'Cough & Cold',
    ),
    PharmacyProduct(
      id: '7',
      name: 'Decolgen',
      localImagePath: 'lib/Images/Decolgen.png',
      price: 6.75,
      stock: 65,
      stockStatus: 'In Stock',
      description: 'Decongestant for nasal congestion and colds.',
      category: 'Cough & Cold',
    ),
    PharmacyProduct(
      id: '8',
      name: 'Lagundi Syrup',
      localImagePath: 'lib/Images/Lagundi Syrup.png',
      price: 85.00,
      stock: 40,
      stockStatus: 'In Stock',
      description: 'Herbal cough remedy. 120ml bottle.',
      category: 'Cough & Cold',
    ),
    
    // Antibiotics
    PharmacyProduct(
      id: '9',
      name: 'Amoxicillin 500mg',
      localImagePath: 'lib/Images/Amoxicillin 500mg.png',
      price: 12.00,
      stock: 30,
      stockStatus: 'Limited Stock',
      description: 'Broad-spectrum antibiotic. Prescription required.',
      category: 'Antibiotics',
    ),
    PharmacyProduct(
      id: '10',
      name: 'Azithromycin',
      localImagePath: 'lib/Images/Azithromycin.png',
      price: 25.00,
      stock: 45,
      stockStatus: 'In Stock',
      description: 'Antibiotic for respiratory infections. Prescription required.',
      category: 'Antibiotics',
    ),
    PharmacyProduct(
      id: '11',
      name: 'Cefalexin',
      localImagePath: 'lib/Images/Cefalexin.png',
      price: 15.00,
      stock: 50,
      stockStatus: 'In Stock',
      description: 'Cephalosporin antibiotic. Prescription required.',
      category: 'Antibiotics',
    ),
    
    // Vitamins
    PharmacyProduct(
      id: '12',
      name: 'Vitamin C (Cecon)',
      localImagePath: 'lib/Images/Vitamin C (Cecon).png',
      price: 5.50,
      stock: 120,
      stockStatus: 'In Stock',
      description: 'Immune system support. 500mg chewable tablets.',
      category: 'Vitamins',
    ),
    PharmacyProduct(
      id: '13',
      name: 'Multivitamins (Enervon)',
      localImagePath: 'lib/Images/Multivitamins (Enervon).png',
      price: 7.25,
      stock: 100,
      stockStatus: 'In Stock',
      description: 'Complete daily multivitamin with B-complex.',
      category: 'Vitamins',
    ),
    PharmacyProduct(
      id: '14',
      name: 'Vitamin B Complex',
      localImagePath: 'lib/Images/Vitamin B Complex.png',
      price: 6.00,
      stock: 85,
      stockStatus: 'In Stock',
      description: 'Energy and metabolism support.',
      category: 'Vitamins',
    ),
    PharmacyProduct(
      id: '15',
      name: 'Fish Oil',
      localImagePath: 'lib/Images/Fish Oil.png',
      price: 12.50,
      stock: 55,
      stockStatus: 'In Stock',
      description: 'Omega-3 supplement for heart health. 1000mg softgels.',
      category: 'Vitamins',
    ),
    
    // First Aid
    PharmacyProduct(
      id: '16',
      name: 'Alcohol 70% (100ml)',
      localImagePath: 'lib/Images/biogenic isopropyl alcohol.png',
      price: 35.00,
      stock: 150,
      stockStatus: 'In Stock',
      description: 'Antiseptic for wound cleaning and disinfection.',
      category: 'First Aid',
    ),
    PharmacyProduct(
      id: '17',
      name: 'Alcohol 70% (500ml)',
      localImagePath: 'lib/Images/biogenic isopropyl alcohol.png',
      price: 120.00,
      stock: 80,
      stockStatus: 'In Stock',
      description: 'Large antiseptic bottle for home use.',
      category: 'First Aid',
    ),
    PharmacyProduct(
      id: '18',
      name: 'Cotton Balls',
      localImagePath: 'lib/Images/Cotton Balls.png',
      price: 25.00,
      stock: 200,
      stockStatus: 'In Stock',
      description: 'Sterile cotton balls for wound care. Pack of 100.',
      category: 'First Aid',
    ),
    PharmacyProduct(
      id: '19',
      name: 'Band Aid (Box)',
      localImagePath: 'lib/Images/Band Aid (Box).png',
      price: 45.00,
      stock: 90,
      stockStatus: 'In Stock',
      description: 'Assorted sizes adhesive bandages. Box of 50.',
      category: 'First Aid',
    ),
    PharmacyProduct(
      id: '20',
      name: 'Hydrogen Peroxide',
      localImagePath: 'lib/Images/Hydrogen Peroxide.png',
      price: 30.00,
      stock: 70,
      stockStatus: 'In Stock',
      description: 'Antiseptic solution for wound cleaning. 100ml.',
      category: 'First Aid',
    ),
    
    // Personal Care
    PharmacyProduct(
      id: '21',
      name: 'Face Mask (Pack of 10)',
      localImagePath: 'lib/Images/Face Mask.png',
      price: 50.00,
      stock: 300,
      stockStatus: 'In Stock',
      description: '3-ply disposable face masks for protection.',
      category: 'Personal Care',
    ),
    PharmacyProduct(
      id: '22',
      name: 'Digital Thermometer',
      localImagePath: 'lib/Images/Digital Thermometer.png',
      price: 150.00,
      stock: 40,
      stockStatus: 'In Stock',
      description: 'Fast and accurate temperature readings.',
      category: 'Personal Care',
    ),
    PharmacyProduct(
      id: '23',
      name: 'Blood Pressure Monitor',
      localImagePath: 'lib/Images/Blood Pressure Monitor.png',
      price: 1200.00,
      stock: 15,
      stockStatus: 'In Stock',
      description: 'Automatic digital BP monitor with memory function.',
      category: 'Personal Care',
    ),
    
    // Others
    PharmacyProduct(
      id: '24',
      name: 'Oral Rehydration Salts (ORS)',
      localImagePath: 'lib/Images/Oral Rehydration Salts.png',
      price: 10.00,
      stock: 120,
      stockStatus: 'In Stock',
      description: 'Electrolyte replacement for dehydration. 4 sachets.',
      category: 'Others',
    ),
    PharmacyProduct(
      id: '25',
      name: 'Antacid (Kremil-S)',
      localImagePath: 'lib/Images/Antacid (Kremil-S).png',
      price: 4.50,
      stock: 100,
      stockStatus: 'In Stock',
      description: 'Fast relief for heartburn and acid indigestion.',
      category: 'Others',
    ),
    PharmacyProduct(
      id: '26',
      name: 'Loperamide (Diatabs)',
      localImagePath: 'lib/Images/Loperamide (Diatabs).png',
      price: 6.75,
      stock: 80,
      stockStatus: 'In Stock',
      description: 'Anti-diarrheal medication. 2mg capsules.',
      category: 'Others',
    ),
  ];

  static List<PharmacyProduct> getProductsByCategory(String category) {
    if (category == 'All') return allProducts;
    return allProducts.where((p) => p.category == category).toList();
  }

  static List<PharmacyProduct> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return allProducts.where((p) => 
      p.name.toLowerCase().contains(lowerQuery) ||
      p.category.toLowerCase().contains(lowerQuery) ||
      p.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
