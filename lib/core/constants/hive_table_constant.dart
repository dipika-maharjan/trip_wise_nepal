class HiveTableConstant {
  // Private constructor
  HiveTableConstant._();

  // Database name
  static const String dbName = "trip_wise_nepal_db";

  // Tables -> Box : Index
  // Authentication
  static const int authTypeId = 0;
  static const String authTable = "auth_table";

  // User Profile
  static const int userTypeId = 1;
  static const String userTable = "user_table";

  // Trips
  static const int tripTypeId = 2;
  static const String tripTable = "trip_table";

  // Itinerary/Destinations
  static const int itineraryTypeId = 3;
  static const String itineraryTable = "itinerary_table";

  // Expenses/Budget
  static const int expenseTypeId = 4;
  static const String expenseTable = "expense_table";

  // Favorites
  static const int favoriteTypeId = 5;
  static const String favoriteTable = "favorite_table";
}