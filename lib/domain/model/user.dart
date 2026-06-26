// lib/domain/model/user.dart

class User {
  final int    id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool   isStaff;
  final bool   isActive;
  final String dateJoined;
  final int    numOrders;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.isActive,
    required this.dateJoined,
    required this.numOrders,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id:         j['id']          as int,
    username:   j['username']    as String,
    email:      j['email']       as String,
    firstName:  j['first_name']  as String,
    lastName:   j['last_name']   as String,
    isStaff:    j['is_staff']    as bool,
    isActive:   j['is_active']   as bool,
    dateJoined: j['date_joined'] as String,
    numOrders:  j['num_orders']  as int,
  );

  Map<String, dynamic> toJson() => {
    'username':   username,
    'email':      email,
    'first_name': firstName,
    'last_name':  lastName,
    'is_staff':   isStaff,
    'is_active':  isActive,
  };

  User copyWith({bool? isStaff, bool? isActive}) => User(
    id:         id,
    username:   username,
    email:      email,
    firstName:  firstName,
    lastName:   lastName,
    isStaff:    isStaff  ?? this.isStaff,
    isActive:   isActive ?? this.isActive,
    dateJoined: dateJoined,
    numOrders:  numOrders,
  );
}