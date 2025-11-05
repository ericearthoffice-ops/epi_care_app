/// 복용 약품 모델
class Medication {
  final String englishName;
  final String koreanName;
  bool isSelected;

  Medication({
    required this.englishName,
    required this.koreanName,
    this.isSelected = false,
  });

  /// 전체 약품 리스트
  static List<Medication> getAllMedications() {
    return [
      Medication(englishName: 'ACTH', koreanName: '부신피질자극호르몬'),
      Medication(englishName: 'Cannabidiol', koreanName: '칸나비디올/CBD 경구용 용액'),
      Medication(englishName: 'Carbamazepine', koreanName: '카르바마제핀'),
      Medication(englishName: 'Clobazam', koreanName: '클로바잠'),
      Medication(englishName: 'Clonazepam', koreanName: '클로나제팜'),
      Medication(englishName: 'Diazepam', koreanName: '디아제팜'),
      Medication(englishName: 'Ethosuximide', koreanName: '에토숙시마이드'),
      Medication(englishName: 'Fenfluramine', koreanName: '펜플루라민'),
      Medication(englishName: 'Gabapentin', koreanName: '가바펜틴'),
      Medication(englishName: 'Lacosamide', koreanName: '라코사미드'),
      Medication(englishName: 'Lamotrigine', koreanName: '라모트리진'),
      Medication(englishName: 'Levetiracetam', koreanName: '레비티라세탐'),
      Medication(englishName: 'Lorazepam', koreanName: '로라제팜'),
      Medication(englishName: 'Oxcarbazepine', koreanName: '옥스카르바제핀'),
      Medication(englishName: 'Phenobarbital', koreanName: '페노바르비탈'),
      Medication(englishName: 'Phenytoin', koreanName: '페니토인'),
      Medication(englishName: 'Prednisolone', koreanName: '프레드니솔론'),
      Medication(englishName: 'Pregabalin', koreanName: '프레가발린'),
      Medication(englishName: 'Rufinamide', koreanName: '루피나마이드'),
      Medication(englishName: 'Stiripentol', koreanName: '스티리펜톨'),
      Medication(englishName: 'Topiramate', koreanName: '토피라메이트'),
      Medication(englishName: 'Valproate', koreanName: '발프로산'),
      Medication(englishName: 'Vigabatrin', koreanName: '비가바트린'),
      Medication(englishName: 'Zonisamide', koreanName: '조니사마이드'),
    ];
  }

  String get displayName => '$englishName ($koreanName)';
}
