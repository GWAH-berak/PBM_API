// Representasi data pengguna yang sedang aktif/login
class UserModel {
  final int id;
  final String nama;
  final String namaUser;
  final RoleModel peran;
  final ClassModel kelasPengguna;

  UserModel({
    required this.id,
    required this.nama,
    required this.namaUser,
    required this.peran,
    required this.kelasPengguna,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nama: json['name'],
      namaUser: json['username'],
      peran: RoleModel.fromJson(json['role']),
      kelasPengguna: ClassModel.fromJson(json['class']),
    );
  }
}

class RoleModel {
  final int id;
  final String nama;

  RoleModel({required this.id, required this.nama});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(id: json['id'], nama: json['name']);
  }
}

class ClassModel {
  final int id;
  final String nama;

  ClassModel({required this.id, required this.nama});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(id: json['id'], nama: json['name']);
  }
}