import 'package:cloud_firestore/cloud_firestore.dart';

// Helper function for DateTime/Timestamp conversion
DateTime? _dateTimeFromTimestamp(Timestamp? timestamp) => timestamp?.toDate();
Timestamp? _dateTimeToTimestamp(DateTime? dateTime) =>
    dateTime == null ? null : Timestamp.fromDate(dateTime);

enum Gender { male, female, other }

class Child {
  final String id;
  final String parentId; // The user ID of the parent
  final String name;
  final DateTime dateOfBirth;
  final Gender? gender;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  Child({
    required this.id,
    required this.parentId,
    required this.name,
    required this.dateOfBirth,
    this.gender,
    required this.createdAt,
    this.lastUpdated,
  });

  // Calculate age in months (total months since birth)
  int get ageInMonths {
    final now = DateTime.now();
    final years = now.year - dateOfBirth.year;
    final months = now.month - dateOfBirth.month;
    final totalMonths = years * 12 + months;
    
    // If the day hasn't passed this month, subtract one month
    if (now.day < dateOfBirth.day) {
      return totalMonths - 1;
    }
    return totalMonths;
  }

  // Calculate age in years (completed years, not rounded)
  int get ageInYears {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    
    // Check if birthday has occurred this year
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
    }
    
    return years;
  }

  // Get age as a readable string
  String get ageString {
    final years = ageInYears;
    final totalMonths = ageInMonths;
    final remainingMonths = totalMonths % 12;

    if (years == 0) {
      // Less than 1 year old
      if (totalMonths == 0) {
        // Less than 1 month old - calculate days
        final now = DateTime.now();
        final days = now.difference(dateOfBirth).inDays;
        if (days == 0) {
          return 'Recién nacido';
        }
        return '$days día${days != 1 ? 's' : ''}';
      }
      return '$totalMonths mes${totalMonths != 1 ? 'es' : ''}';
    } else if (remainingMonths == 0) {
      // Exact years (e.g., exactly 2 years)
      return '$years año${years != 1 ? 's' : ''}';
    } else {
      // Years and months
      return '$years año${years != 1 ? 's' : ''} y $remainingMonths mes${remainingMonths != 1 ? 'es' : ''}';
    }
  }

  // Factory constructor from Firestore
  factory Child.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;

    return Child(
      id: doc.id,
      parentId: data['parentId'] as String,
      name: data['name'] as String,
      dateOfBirth: _dateTimeFromTimestamp(data['dateOfBirth'] as Timestamp?) ??
          DateTime.now(),
      gender: data['gender'] != null
          ? Gender.values.firstWhere(
              (e) => e.toString() == data['gender'],
              orElse: () => Gender.other,
            )
          : null,
      createdAt: _dateTimeFromTimestamp(data['createdAt'] as Timestamp?) ??
          DateTime.now(),
      lastUpdated: _dateTimeFromTimestamp(data['lastUpdated'] as Timestamp?),
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'parentId': parentId,
      'name': name,
      'dateOfBirth': _dateTimeToTimestamp(dateOfBirth),
      'gender': gender?.toString(),
      'createdAt': _dateTimeToTimestamp(createdAt),
      'lastUpdated': _dateTimeToTimestamp(DateTime.now()),
    };
  }

  // Copy with method
  Child copyWith({
    String? id,
    String? parentId,
    String? name,
    DateTime? dateOfBirth,
    Gender? gender,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Child(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
