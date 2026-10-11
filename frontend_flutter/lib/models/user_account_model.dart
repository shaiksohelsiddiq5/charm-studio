class UserAccount {
  final String id;
  final String name;
  final String email;
  final String role; // 'brand' or 'creator'
  final String companyName;
  final String avatarText;
  final String avatar;
  final String description;

  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.companyName = '',
    this.avatarText = '',
    this.avatar = '',
    this.description = '',
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    final String name = (json['name'] ?? 'User').toString();
    String initials = (json['avatarText'] ?? '').toString();
    if (initials.isEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (name.isNotEmpty) {
        initials = name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
      } else {
        initials = 'U';
      }
    }

    return UserAccount(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: name,
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'brand').toString(),
      companyName: (json['companyName'] ?? '').toString(),
      avatarText: initials,
      avatar: (json['avatar'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'companyName': companyName,
    'avatarText': avatarText,
    'avatar': avatar,
    'description': description,
  };

  bool get isBrand => role.toLowerCase() == 'brand';
  bool get isCreator => role.toLowerCase() == 'creator';

  static const defaultBrand = UserAccount(
    id: 'demo_brand_1',
    name: 'Aura Beverages',
    email: 'brand@aurabev.com',
    role: 'brand',
    companyName: 'Aura Beverages Co.',
    avatarText: 'AB',
    description: 'Brand Enterprise Organization Account',
  );

  static const List<UserAccount> defaultDemoAccounts = [
    defaultBrand,
    UserAccount(
      id: 'demo_creator_user_1',
      name: 'Aria Chen',
      email: 'aria@ai-creators.io',
      role: 'creator',
      companyName: 'AI Culinary Studio',
      avatarText: 'AC',
      avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
      description: 'AI Culinary Visualist & Commercial Specialist',
    ),
    UserAccount(
      id: 'demo_creator_user_2',
      name: 'Marcus Vance',
      email: 'marcus@cinematic-ai.com',
      role: 'creator',
      companyName: 'Cinematic AI Productions',
      avatarText: 'MV',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      description: 'Sci-Fi & Commercial Filmmaker',
    ),
    UserAccount(
      id: 'demo_creator_user_3',
      name: 'Elena Rostova',
      email: 'elena@anim-lab.studio',
      role: 'creator',
      companyName: 'Anim Lab Studio',
      avatarText: 'ER',
      avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
      description: 'Hybrid AI Animator & Motion Graphics',
    ),
    UserAccount(
      id: 'demo_creator_user_6',
      name: 'Aarav Sharma',
      email: 'aarav@generative-motion.ai',
      role: 'creator',
      companyName: 'Generative Motion VFX',
      avatarText: 'AS',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      description: 'Macro Liquid VFX & Runway Gen-3 Director',
    ),
  ];
}
