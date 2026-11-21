// Nombres de las colecciones de Cloud Firestore usadas por LostPaws.
//
// Estructura de la base de datos:
//
//   users/{uid}            -> UserModel      (perfil de cada usuario)
//   pet_reports/{reportId} -> PetReportModel (mascotas perdidas / encontradas)
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String petReports = 'pet_reports';
}
