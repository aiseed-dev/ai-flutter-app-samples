// JSONの構造をDartのクラスとして定義する。
// これで型安全にデータにアクセスできるようになり、typoなどのミスを防げる。
class Gym {
  final int id;
  final String name;
  final String? region;
  final String? prefecture;
  final String? city;
  final String? address;
  final String? access;
  final String? website;
  final String? phoneNumber;
  final double? wallArea;
  final double? wallHeight;
  final String? hasLead;
  final String? hasCrack;
  final String? hasTopRope;
  final String? hasAutoBelay;
  final String? hasParking;
  final String? hasShower;
  final String? hasShop;
  final String? notes;

  // コンストラクタ
  Gym({
    required this.id,
    required this.name,
    this.region,
    this.prefecture,
    this.city,
    this.address,
    this.access,
    this.website,
    this.phoneNumber,
    this.wallArea,
    this.wallHeight,
    this.hasLead,
    this.hasCrack,
    this.hasTopRope,
    this.hasAutoBelay,
    this.hasParking,
    this.hasShower,
    this.hasShop,
    this.notes,
  });

  // JSONのMap<String, dynamic>からGymオブジェクトを生成するファクトリコンストラクタ。
  // 「このfromJsonという仕組みがあれば、JSONのキーとクラスのプロパティを
  //   一つずつ、間違いなく紐付けられるんだ」と美咲は理解した。
  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'],
      name: json['name'] ?? '名前不明', // nameは必須なので、万が一nullならデフォルト値を入れる
      region: json['region'],
      prefecture: json['prefecture'],
      city: json['city'],
      address: json['address'],
      access: json['access'],
      website: json['website'],
      phoneNumber: json['phone_number'],
      // JSONの数値はintかもしれないので、安全にdouble?型に変換
      wallArea: (json['wall_area'] as num?)?.toDouble(), 
      wallHeight: (json['wall_height'] as num?)?.toDouble(),
      hasLead: json['has_lead'],
      hasCrack: json['has_crack'],
      hasTopRope: json['has_top_rope'],
      hasAutoBelay: json['has_auto_belay'],
      hasParking: json['has_parking'],
      hasShower: json['has_shower'],
      hasShop: json['has_shop'],
      notes: json['notes'],
    );
  }
}