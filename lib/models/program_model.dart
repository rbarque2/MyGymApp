import 'exercise_model.dart';

/// Modelo de datos local para programas predefinidos de ZarpaFit.
/// No se persiste en Firestore — son catálogos estáticos.

/// Ejercicio dentro de un programa predefinido.
class ProgramExercise {
  ProgramExercise({
    required this.name,
    this.sets = 3,
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.distanceMeters,
    this.restSeconds = 45,
    this.measurementType = MeasurementType.reps,
    this.photoUrl,
    String? gifUrl,
    this.notes,
    this.order = 0,
  }) : gifUrl = gifUrl ?? _gifLibrary[name];

  final String name;
  final int sets;
  final int? reps;
  final double? weightKg;
  final int? durationSeconds;
  final double? distanceMeters;
  final int restSeconds;
  final MeasurementType measurementType;
  final String? photoUrl;
  final String? gifUrl;
  final String? notes;
  final int order;

  /// Biblioteca central de GIFs por nombre de ejercicio.
  ///
  /// Actúa como fallback cuando un [ProgramExercise] se construye sin
  /// [gifUrl] explícito. Permite que muchos nombres compartan un mismo
  /// recurso (dedupe) y que nuevos programas obtengan gif automáticamente
  /// si el nombre ya está cubierto aquí.
  static const Map<String, String> _gifLibrary = {
    // ── Pecho ──
    'Press banca':
        'https://fitcron.com/wp-content/uploads/2021/03/00251301-Barbell-Bench-Press_Chest-FIX_720.gif',
    'Press banca plano':
        'https://fitcron.com/wp-content/uploads/2021/03/00251301-Barbell-Bench-Press_Chest-FIX_720.gif',
    'Press banca solo barra':
        'https://fitcron.com/wp-content/uploads/2021/03/00251301-Barbell-Bench-Press_Chest-FIX_720.gif',
    'Press banca · 5/3/1':
        'https://fitcron.com/wp-content/uploads/2021/03/00251301-Barbell-Bench-Press_Chest-FIX_720.gif',
    'Upper · Press banca':
        'https://fitcron.com/wp-content/uploads/2021/03/00251301-Barbell-Bench-Press_Chest-FIX_720.gif',
    'Push · Press banca':
        'https://fitcron.com/wp-content/uploads/2021/03/00251301-Barbell-Bench-Press_Chest-FIX_720.gif',
    'Press inclinado mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/03/03241301-Dumbbell-Incline-Palm-in-Press_Chest_720.gif',
    'Push · Press inclinado mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/03/03241301-Dumbbell-Incline-Palm-in-Press_Chest_720.gif',
    'Press inclinado barra':
        'https://fitcron.com/wp-content/uploads/2021/03/03241301-Dumbbell-Incline-Palm-in-Press_Chest_720.gif',
    'Press declinado':
        'https://fitcron.com/wp-content/uploads/2021/03/03031301-Dumbbell-Decline-Hammer-Press_Chest_720.gif',
    'Press declinado mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/03/03031301-Dumbbell-Decline-Hammer-Press_Chest_720.gif',
    'Aperturas con mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/03/03081301-Dumbbell-Fly_Chest-FIX_720.gif',
    'Aperturas en banco inclinado':
        'https://fitcron.com/wp-content/uploads/2021/03/03081301-Dumbbell-Fly_Chest-FIX_720.gif',
    'Cruces en polea alta':
        'https://fitcron.com/wp-content/uploads/2021/03/12701301-Cable-Upper-Chest-Crossovers_Chest_720.gif',
    'Cruce en polea alta':
        'https://fitcron.com/wp-content/uploads/2021/03/12701301-Cable-Upper-Chest-Crossovers_Chest_720.gif',
    'Cruce en polea baja':
        'https://fitcron.com/wp-content/uploads/2021/03/12701301-Cable-Upper-Chest-Crossovers_Chest_720.gif',
    'Fondos en paralelas':
        'https://fitcron.com/wp-content/uploads/2021/03/02511301-Chest-Dip_Chest_720.gif',
    'Fondos en paralelas lastrados':
        'https://fitcron.com/wp-content/uploads/2021/03/02511301-Chest-Dip_Chest_720.gif',
    'Pull-over con mancuerna':
        'https://fitcron.com/wp-content/uploads/2021/03/03751301-Dumbbell-Pullover_Chest_720.gif',
    'Pull-over en polea':
        'https://fitcron.com/wp-content/uploads/2021/03/01841301-Cable-Lying-Extension-Pullover-with-rope-attachment_Back_720.gif',
    'Flexiones':
        'https://fitcron.com/wp-content/uploads/2021/03/06621301-Push-up-m_Chest-FIX_720.gif',
    'Flexiones explosivas':
        'https://fitcron.com/wp-content/uploads/2021/03/06621301-Push-up-m_Chest-FIX_720.gif',
    'Flexiones en pared':
        'https://fitcron.com/wp-content/uploads/2021/03/06621301-Push-up-m_Chest-FIX_720.gif',
    'Flexiones progresivas':
        'https://fitcron.com/wp-content/uploads/2021/03/06621301-Push-up-m_Chest-FIX_720.gif',
    'Push-up burnout':
        'https://fitcron.com/wp-content/uploads/2021/03/06621301-Push-up-m_Chest-FIX_720.gif',
    'Flexiones diamante':
        'https://fitcron.com/wp-content/uploads/2021/03/02831301-Diamond-Push-up_Upper-Arms_720.gif',

    // ── Espalda ──
    'Jalón al pecho':
        'https://fitcron.com/wp-content/uploads/2021/04/01981301-Cable-Pulldown_Back_720.gif',
    'Upper · Jalón al pecho':
        'https://fitcron.com/wp-content/uploads/2021/04/01981301-Cable-Pulldown_Back_720.gif',
    'Jalón agarre neutro':
        'https://fitcron.com/wp-content/uploads/2021/04/01981301-Cable-Pulldown_Back_720.gif',
    'Dominadas o jalón':
        'https://fitcron.com/wp-content/uploads/2021/04/14291301-Wide-Grip-Pull-Up_Back_720.gif',
    'Pull · Dominadas o jalón':
        'https://fitcron.com/wp-content/uploads/2021/04/14291301-Wide-Grip-Pull-Up_Back_720.gif',
    'Dominadas lastradas':
        'https://fitcron.com/wp-content/uploads/2021/04/14291301-Wide-Grip-Pull-Up_Back_720.gif',
    'Dominadas asistidas':
        'https://fitcron.com/wp-content/uploads/2021/04/06271301-Mixed-Grip-Chin-up_back_720.gif',
    'Remo con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/00491301-Barbell-Incline-Row_Back_720.gif',
    'Remo barra o máquina':
        'https://fitcron.com/wp-content/uploads/2021/04/00271301-Barbell-Bent-Over-Row_Back-FIX_720.gif',
    'Pull · Remo con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/00271301-Barbell-Bent-Over-Row_Back-FIX_720.gif',
    'Upper · Remo con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/00271301-Barbell-Bent-Over-Row_Back-FIX_720.gif',
    'Remo Pendlay':
        'https://fitcron.com/wp-content/uploads/2021/04/00271301-Barbell-Bent-Over-Row_Back-FIX_720.gif',
    'Remo mancuerna a 1 brazo':
        'https://fitcron.com/wp-content/uploads/2021/04/02921301-Dumbbell-Bent-over-Row_back_Back_720.gif',
    'Pull · Remo mancuerna':
        'https://fitcron.com/wp-content/uploads/2021/04/02921301-Dumbbell-Bent-over-Row_back_Back_720.gif',
    'Remo unilateral':
        'https://fitcron.com/wp-content/uploads/2021/04/02921301-Dumbbell-Bent-over-Row_back_Back_720.gif',
    'Remo en máquina':
        'https://fitcron.com/wp-content/uploads/2021/04/02921301-Dumbbell-Bent-over-Row_back_Back_720.gif',
    'Remo en T':
        'https://fitcron.com/wp-content/uploads/2021/04/02921301-Dumbbell-Bent-over-Row_back_Back_720.gif',
    'Encogimientos con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/00951301-Barbell-Shrug_Back_720.gif',
    'Encogimientos con mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/04/00951301-Barbell-Shrug_Back_720.gif',
    'Encogimientos pesados':
        'https://fitcron.com/wp-content/uploads/2021/04/00951301-Barbell-Shrug_Back_720.gif',

    // ── Hombros ──
    'Elevaciones laterales':
        'https://fitcron.com/wp-content/uploads/2021/04/03801301-Dumbbell-Rear-Lateral-Raise_Shoulders_720.gif',
    'Push · Elevaciones laterales':
        'https://fitcron.com/wp-content/uploads/2021/04/03801301-Dumbbell-Rear-Lateral-Raise_Shoulders_720.gif',
    'Elevaciones frontales':
        'https://fitcron.com/wp-content/uploads/2021/04/03801301-Dumbbell-Rear-Lateral-Raise_Shoulders_720.gif',
    'Pájaros (rear delt)':
        'https://fitcron.com/wp-content/uploads/2021/04/03801301-Dumbbell-Rear-Lateral-Raise_Shoulders_720.gif',
    'Face pull':
        'https://fitcron.com/wp-content/uploads/2021/04/36971301-Cable-Kneeling-Rear-Delt-Row-with-rope-male_Shoulder_720.gif',
    'Face pull ligero':
        'https://fitcron.com/wp-content/uploads/2021/04/36971301-Cable-Kneeling-Rear-Delt-Row-with-rope-male_Shoulder_720.gif',
    'Pull · Face pull':
        'https://fitcron.com/wp-content/uploads/2021/04/36971301-Cable-Kneeling-Rear-Delt-Row-with-rope-male_Shoulder_720.gif',

    // ── Bíceps ──
    'Curl alterno con mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl bíceps':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl con mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl ligero con mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl martillo':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl martillo cruzado':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl concentrado':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl predicador':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl Zottman':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl tipo Zottman':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Pull · Curl martillo':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Pull · Curl barra':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Upper · Curl alterno':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl 21s con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl cable barra recta':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',
    'Curl en polea baja':
        'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif',

    // ── Tríceps (se reutiliza Bench-Dip) ──
    'Fondos en banco':
        'https://fitcron.com/wp-content/uploads/2021/04/02981301-Dumbbell-Bench-Dip_Triceps_720.gif',

    // ── Piernas ──
    'Sentadilla con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif',
    'Sentadilla':
        'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif',
    'Sentadilla con peso corporal':
        'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif',
    'Sentadilla profunda':
        'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif',
    'Sentadilla con talones elevados':
        'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif',
    'Sentadilla profunda isométrica':
        'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif',
    'Sentadilla · 5/3/1':
        'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif',
    'Legs · Sentadilla con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif',
    'Lower · Sentadilla':
        'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif',
    'Sentadilla pistol asistida':
        'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif',
    'Prensa inclinada':
        'https://fitcron.com/wp-content/uploads/2021/04/07401301-Sled-45%C2%B0-Leg-Wide-Press_Thighs_720.gif',
    'Prensa de piernas':
        'https://fitcron.com/wp-content/uploads/2021/04/07401301-Sled-45%C2%B0-Leg-Wide-Press_Thighs_720.gif',
    'Legs · Prensa':
        'https://fitcron.com/wp-content/uploads/2021/04/07401301-Sled-45%C2%B0-Leg-Wide-Press_Thighs_720.gif',
    'Extensión de cuádriceps':
        'https://fitcron.com/wp-content/uploads/2021/04/05851301-Lever-Leg-Extension_Thighs_720.gif',
    'Lower · Extensión cuádriceps':
        'https://fitcron.com/wp-content/uploads/2021/04/05851301-Lever-Leg-Extension_Thighs_720.gif',
    'Curl femoral acostado':
        'https://fitcron.com/wp-content/uploads/2021/04/05861301-Lever-Lying-Leg-Curl_Thighs_720.gif',
    'Curl femoral tumbado':
        'https://fitcron.com/wp-content/uploads/2021/04/05991301-Lever-Seated-Leg-Curl_Thighs-FIX_720.gif',
    'Legs · Curl femoral':
        'https://fitcron.com/wp-content/uploads/2021/04/05991301-Lever-Seated-Leg-Curl_Thighs-FIX_720.gif',
    'Lower · Curl femoral':
        'https://fitcron.com/wp-content/uploads/2021/04/05991301-Lever-Seated-Leg-Curl_Thighs-FIX_720.gif',
    'Zancadas':
        'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif',
    'Zancadas caminando':
        'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif',
    'Zancadas con mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif',
    'Zancada profunda':
        'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif',
    'Zancada dinámica':
        'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif',
    'Zancada con rotación':
        'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif',
    'Lower · Zancada con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif',
    'Sentadilla lateral profunda':
        'https://fitcron.com/wp-content/uploads/2021/04/34481301-Dumbbell-Side-Lunge-VERSION-3_720.gif',
    'Sentadilla con salto':
        'https://fitcron.com/wp-content/uploads/2021/04/15521301-Dumbbell-Jumping-Squat_Plyometric_720.gif',
    'Sentadilla búlgara':
        'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif',
    'Sentadilla búlgara con mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif',
    'Step-up con mancuernas':
        'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif',

    // ── Glúteos ──
    'Hip thrust':
        'https://fitcron.com/wp-content/uploads/2021/04/29641301-Barbell-Glute-Bridge-hands-on-bar_Hips_720.gif',
    'Hip thrust con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/29641301-Barbell-Glute-Bridge-hands-on-bar_Hips_720.gif',
    'Legs · Hip thrust':
        'https://fitcron.com/wp-content/uploads/2021/04/29641301-Barbell-Glute-Bridge-hands-on-bar_Hips_720.gif',
    'Lower · Hip thrust':
        'https://fitcron.com/wp-content/uploads/2021/04/29641301-Barbell-Glute-Bridge-hands-on-bar_Hips_720.gif',
    'Puente bajo':
        'https://fitcron.com/wp-content/uploads/2021/04/29641301-Barbell-Glute-Bridge-hands-on-bar_Hips_720.gif',
    'Puente con banda':
        'https://fitcron.com/wp-content/uploads/2021/04/29641301-Barbell-Glute-Bridge-hands-on-bar_Hips_720.gif',
    'Puente de glúteo con banda':
        'https://fitcron.com/wp-content/uploads/2021/04/29641301-Barbell-Glute-Bridge-hands-on-bar_Hips_720.gif',

    // ── Peso muerto / hip hinge ──
    'Peso muerto rumano':
        'https://fitcron.com/wp-content/uploads/2021/04/00851301-Barbell-Romanian-Deadlift_Hips_720.gif',
    'Legs · Peso muerto rumano':
        'https://fitcron.com/wp-content/uploads/2021/04/00851301-Barbell-Romanian-Deadlift_Hips_720.gif',
    'Lower · Peso muerto rumano':
        'https://fitcron.com/wp-content/uploads/2021/04/00851301-Barbell-Romanian-Deadlift_Hips_720.gif',
    'Peso muerto convencional':
        'https://fitcron.com/wp-content/uploads/2021/04/00851301-Barbell-Romanian-Deadlift_Hips_720.gif',
    'Peso muerto sumo':
        'https://fitcron.com/wp-content/uploads/2021/04/00851301-Barbell-Romanian-Deadlift_Hips_720.gif',
    'Peso muerto · 5/3/1':
        'https://fitcron.com/wp-content/uploads/2021/04/00851301-Barbell-Romanian-Deadlift_Hips_720.gif',
    'Good morning con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/00851301-Barbell-Romanian-Deadlift_Hips_720.gif',
    'Buenos días con barra':
        'https://fitcron.com/wp-content/uploads/2021/04/00851301-Barbell-Romanian-Deadlift_Hips_720.gif',

    // ── Gemelos ──
    'Elevación de gemelos':
        'https://fitcron.com/wp-content/uploads/2021/04/04171301-Dumbbell-Standing-Calf-Raise_Calf_720.gif',
    'Gemelo de pie en máquina':
        'https://fitcron.com/wp-content/uploads/2021/04/04171301-Dumbbell-Standing-Calf-Raise_Calf_720.gif',
    'Gemelo sentado':
        'https://fitcron.com/wp-content/uploads/2021/04/04171301-Dumbbell-Standing-Calf-Raise_Calf_720.gif',
    'Gemelo en prensa':
        'https://fitcron.com/wp-content/uploads/2021/04/04171301-Dumbbell-Standing-Calf-Raise_Calf_720.gif',
    'Gemelos a 1 pierna con mancuerna':
        'https://fitcron.com/wp-content/uploads/2021/04/04171301-Dumbbell-Standing-Calf-Raise_Calf_720.gif',
    'Legs · Gemelos de pie':
        'https://fitcron.com/wp-content/uploads/2021/04/04171301-Dumbbell-Standing-Calf-Raise_Calf_720.gif',
    'Lower · Gemelos':
        'https://fitcron.com/wp-content/uploads/2021/04/04171301-Dumbbell-Standing-Calf-Raise_Calf_720.gif',
    'Press de pantorrilla':
        'https://fitcron.com/wp-content/uploads/2021/04/13831301-Hack-Calf-Raise_Calves_720.gif',

    // ── Abdominales / core ──
    'Crunch abdominal':
        'https://fitcron.com/wp-content/uploads/2024/05/43321301-Crunch-Hold_Waist_720.gif',
    'Cable crunch arrodillado':
        'https://fitcron.com/wp-content/uploads/2024/05/43321301-Crunch-Hold_Waist_720.gif',
    'Hollow hold':
        'https://fitcron.com/wp-content/uploads/2024/05/12461301-Hollow-Hold_Waist_720.gif',
    'Hollow rocks':
        'https://fitcron.com/wp-content/uploads/2024/05/12461301-Hollow-Hold_Waist_720.gif',
    'Bicicleta':
        'https://fitcron.com/wp-content/uploads/2024/05/02621301-Cross-Body-Crunch_waist_720.gif',
    'Russian twist':
        'https://fitcron.com/wp-content/uploads/2024/05/02621301-Cross-Body-Crunch_waist_720.gif',
    'Russian twist con disco':
        'https://fitcron.com/wp-content/uploads/2024/05/02621301-Cross-Body-Crunch_waist_720.gif',
    'Elevación de piernas':
        'https://fitcron.com/wp-content/uploads/2024/05/28021301-Twisted-Leg-Raise_Waist_720.gif',
    'Elevación de piernas colgado':
        'https://fitcron.com/wp-content/uploads/2024/05/28021301-Twisted-Leg-Raise_Waist_720.gif',
    'Elevación piernas colgado':
        'https://fitcron.com/wp-content/uploads/2024/05/28021301-Twisted-Leg-Raise_Waist_720.gif',
    'Tijeras de pierna':
        'https://fitcron.com/wp-content/uploads/2024/05/28021301-Twisted-Leg-Raise_Waist_720.gif',
    'Plancha frontal':
        'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif',
    'Plancha lateral':
        'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif',
    'Plancha':
        'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif',
    'Plancha frontal lastrada':
        'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif',
    'Plancha lateral con elevación pierna':
        'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif',
    'Plancha lateral con peso':
        'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif',
    'Plancha con toque de hombro':
        'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif',
    'Plancha con salto':
        'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif',
    'Upper · Plancha':
        'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif',

    // ── Cardio / HIIT ──
    'Correr':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Trote suave':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Carrera continua':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Caminar rápido':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Caminar rápido en cinta':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Tirada larga':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Fartlek':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Series 400m':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Vuelta a la calma':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Bike o caminar 5 min':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Remo en bicicleta o cinta':
        'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif',
    'Burpees':
        'https://fitcron.com/wp-content/uploads/2021/03/11601301-Burpee_Cardio_720.gif',
    'Mountain climbers':
        'https://fitcron.com/wp-content/uploads/2021/03/06301301-Mountain-Climber_Cardio_720.gif',
    'Rodillas altas':
        'https://fitcron.com/wp-content/uploads/2021/03/31991301-Skips_Cardio_720.gif',
    'Skipping':
        'https://fitcron.com/wp-content/uploads/2021/03/31991301-Skips_Cardio_720.gif',
    'Talones al glúteo':
        'https://fitcron.com/wp-content/uploads/2021/03/31991301-Skips_Cardio_720.gif',
    'Sprint en sitio':
        'https://fitcron.com/wp-content/uploads/2021/03/31991301-Skips_Cardio_720.gif',
    'Saltos de tijera':
        'https://fitcron.com/wp-content/uploads/2021/03/30941301-Jumping-Jack-male_Cardio_720.gif',
    'Saltos de estrella':
        'https://fitcron.com/wp-content/uploads/2021/03/30941301-Jumping-Jack-male_Cardio_720.gif',
    'Skaters laterales':
        'https://fitcron.com/wp-content/uploads/2021/03/30941301-Jumping-Jack-male_Cardio_720.gif',
  };

  /// Descripción corta (e.g. "3×12 · 60s descanso")
  String get summary {
    final parts = <String>[];
    switch (measurementType) {
      case MeasurementType.weight:
        if (reps != null) parts.add('$sets×$reps');
        if (weightKg != null) parts.add('${weightKg}kg');
      case MeasurementType.reps:
        if (reps != null) parts.add('$sets×$reps');
      case MeasurementType.time:
        if (durationSeconds != null) {
          final m = durationSeconds! ~/ 60;
          final s = durationSeconds! % 60;
          parts.add('$sets×${m > 0 ? "${m}m" : ""}${s > 0 ? "${s}s" : ""}');
        }
      case MeasurementType.distance:
        if (distanceMeters != null) {
          parts.add(distanceMeters! >= 1000
              ? '${(distanceMeters! / 1000).toStringAsFixed(1)}km'
              : '${distanceMeters!.toInt()}m');
        }
    }
    parts.add('${restSeconds}s desc.');
    return parts.join(' · ');
  }

  /// Crea un ProgramExercise desde una fila CSV.
  /// Columnas: programId,order,name,sets,reps,weightKg,durationSeconds,
  ///           distanceMeters,restSeconds,measurementType,photoUrl,gifUrl,notes
  factory ProgramExercise.fromCsvRow(List<String> cols) {
    String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();
    int? _intOrNull(String s) => int.tryParse(s.trim());
    double? _doubleOrNull(String s) => double.tryParse(s.trim());

    return ProgramExercise(
      order: _intOrNull(cols.length > 1 ? cols[1] : '') ?? 0,
      name: cols.length > 2 ? cols[2].trim() : '',
      sets: _intOrNull(cols.length > 3 ? cols[3] : '') ?? 3,
      reps: _intOrNull(cols.length > 4 ? cols[4] : ''),
      weightKg: _doubleOrNull(cols.length > 5 ? cols[5] : ''),
      durationSeconds: _intOrNull(cols.length > 6 ? cols[6] : ''),
      distanceMeters: _doubleOrNull(cols.length > 7 ? cols[7] : ''),
      restSeconds: _intOrNull(cols.length > 8 ? cols[8] : '') ?? 45,
      measurementType: MeasurementType.values.firstWhere(
        (m) => m.name == (cols.length > 9 ? cols[9].trim() : ''),
        orElse: () => MeasurementType.reps,
      ),
      photoUrl: _nullIfEmpty(cols.length > 10 ? cols[10] : ''),
      gifUrl: _nullIfEmpty(cols.length > 11 ? cols[11] : ''),
      notes: _nullIfEmpty(cols.length > 12 ? cols[12] : ''),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'sets': sets,
        'reps': reps,
        'weightKg': weightKg,
        'durationSeconds': durationSeconds,
        'distanceMeters': distanceMeters,
        'restSeconds': restSeconds,
        'measurementType': measurementType.name,
        'photoUrl': photoUrl,
        'gifUrl': gifUrl,
        'notes': notes,
        'order': order,
      };

  factory ProgramExercise.fromMap(Map<String, dynamic> m) => ProgramExercise(
        name: m['name'] as String? ?? '',
        sets: (m['sets'] as num?)?.toInt() ?? 3,
        reps: (m['reps'] as num?)?.toInt(),
        weightKg: (m['weightKg'] as num?)?.toDouble(),
        durationSeconds: (m['durationSeconds'] as num?)?.toInt(),
        distanceMeters: (m['distanceMeters'] as num?)?.toDouble(),
        restSeconds: (m['restSeconds'] as num?)?.toInt() ?? 45,
        measurementType: MeasurementType.values.firstWhere(
          (t) => t.name == (m['measurementType'] as String? ?? ''),
          orElse: () => MeasurementType.reps,
        ),
        photoUrl: m['photoUrl'] as String?,
        gifUrl: m['gifUrl'] as String?,
        notes: m['notes'] as String?,
        order: (m['order'] as num?)?.toInt() ?? 0,
      );
}

enum ProgramCategory {
  rapidos('Sesiones rápidas', '⚡'),
  programas('Programas', '📋'),
  calentamientos('Calentamientos', '🔥'),
  estiramientos('Movilidad / Estiramientos', '🧘');

  const ProgramCategory(this.label, this.icon);
  final String label;
  final String icon;
}

enum ProgramLevel {
  inicio('Inicio'),
  intermedio('Intermedio'),
  avanzado('Avanzado'),
  todos('Todos los niveles');

  const ProgramLevel(this.label);
  final String label;
}

class ProgramModel {
  const ProgramModel({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    this.subtitle,
    this.durationMin,
    this.weeks,
    this.daysPerWeek,
    this.exerciseCount,
    this.tags = const [],
    this.emoji = '💪',
    this.equipment,
    this.colorIndex = 0,
    this.imageUrl,
    this.gifUrl,
    this.description,
    this.exercises = const [],
  });

  final String id;
  final String title;
  final ProgramCategory category;
  final ProgramLevel level;
  final String? subtitle;
  final int? durationMin;
  final int? weeks;
  final int? daysPerWeek;
  final int? exerciseCount;
  final List<String> tags;
  final String emoji;
  final String? equipment;
  final int colorIndex;
  final String? imageUrl;
  final String? gifUrl;
  final String? description;
  final List<ProgramExercise> exercises;

  /// Línea descriptiva corta para la tarjeta.
  String get info {
    final parts = <String>[];
    if (weeks != null) {
      parts.add('$weeks semanas');
      if (daysPerWeek != null) parts.add('$daysPerWeek días/sem');
    }
    if (durationMin != null) parts.add('$durationMin min');
    if (exerciseCount != null) parts.add('$exerciseCount ejercicios');
    if (equipment != null) parts.add(equipment!);
    return parts.join(' · ');
  }

  /// Crea un ProgramModel desde una fila CSV.
  /// Columnas: id,title,category,level,subtitle,durationMin,weeks,daysPerWeek,
  ///           exerciseCount,tags,emoji,equipment,colorIndex,imageUrl,gifUrl,description
  factory ProgramModel.fromCsvRow(List<String> cols) {
    String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();
    int? _intOrNull(String s) => int.tryParse(s.trim());

    return ProgramModel(
      id: cols[0].trim(),
      title: cols[1].trim(),
      category: ProgramCategory.values.firstWhere(
        (c) => c.name == cols[2].trim(),
        orElse: () => ProgramCategory.rapidos,
      ),
      level: ProgramLevel.values.firstWhere(
        (l) => l.name == cols[3].trim(),
        orElse: () => ProgramLevel.todos,
      ),
      subtitle: _nullIfEmpty(cols.length > 4 ? cols[4] : ''),
      durationMin: _intOrNull(cols.length > 5 ? cols[5] : ''),
      weeks: _intOrNull(cols.length > 6 ? cols[6] : ''),
      daysPerWeek: _intOrNull(cols.length > 7 ? cols[7] : ''),
      exerciseCount: _intOrNull(cols.length > 8 ? cols[8] : ''),
      tags: cols.length > 9 && cols[9].trim().isNotEmpty
          ? cols[9].split('|').map((t) => t.trim()).toList()
          : [],
      emoji: cols.length > 10 && cols[10].trim().isNotEmpty
          ? cols[10].trim()
          : '💪',
      equipment: _nullIfEmpty(cols.length > 11 ? cols[11] : ''),
      colorIndex: _intOrNull(cols.length > 12 ? cols[12] : '') ?? 0,
      imageUrl: _nullIfEmpty(cols.length > 13 ? cols[13] : ''),
      gifUrl: _nullIfEmpty(cols.length > 14 ? cols[14] : ''),
      description: _nullIfEmpty(cols.length > 15 ? cols[15] : ''),
    );
  }

  /// Devuelve copia con ejercicios asignados (para cargar desde CSV de ejercicios).
  ProgramModel withExercises(List<ProgramExercise> exs) {
    return ProgramModel(
      id: id,
      title: title,
      category: category,
      level: level,
      subtitle: subtitle,
      durationMin: durationMin,
      weeks: weeks,
      daysPerWeek: daysPerWeek,
      exerciseCount: exerciseCount,
      tags: tags,
      emoji: emoji,
      equipment: equipment,
      colorIndex: colorIndex,
      imageUrl: imageUrl,
      gifUrl: gifUrl,
      description: description,
      exercises: exs,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category.name,
        'level': level.name,
        'subtitle': subtitle,
        'durationMin': durationMin,
        'weeks': weeks,
        'daysPerWeek': daysPerWeek,
        'exerciseCount': exerciseCount ?? exercises.length,
        'tags': tags,
        'emoji': emoji,
        'equipment': equipment,
        'colorIndex': colorIndex,
        'imageUrl': imageUrl,
        'gifUrl': gifUrl,
        'description': description,
        'exercises': exercises.map((e) => e.toMap()).toList(),
      };

  factory ProgramModel.fromMap(Map<String, dynamic> m) => ProgramModel(
        id: m['id'] as String? ?? '',
        title: m['title'] as String? ?? '',
        category: ProgramCategory.values.firstWhere(
          (c) => c.name == (m['category'] as String? ?? ''),
          orElse: () => ProgramCategory.rapidos,
        ),
        level: ProgramLevel.values.firstWhere(
          (l) => l.name == (m['level'] as String? ?? ''),
          orElse: () => ProgramLevel.todos,
        ),
        subtitle: m['subtitle'] as String?,
        durationMin: (m['durationMin'] as num?)?.toInt(),
        weeks: (m['weeks'] as num?)?.toInt(),
        daysPerWeek: (m['daysPerWeek'] as num?)?.toInt(),
        exerciseCount: (m['exerciseCount'] as num?)?.toInt(),
        tags: (m['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        emoji: m['emoji'] as String? ?? '💪',
        equipment: m['equipment'] as String?,
        colorIndex: (m['colorIndex'] as num?)?.toInt() ?? 0,
        imageUrl: m['imageUrl'] as String?,
        gifUrl: m['gifUrl'] as String?,
        description: m['description'] as String?,
        exercises: (m['exercises'] as List<dynamic>?)
                ?.map((e) =>
                    ProgramExercise.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

/// Catálogo MVP de programas con ejercicios.
const programsCatalog = <ProgramModel>[
  // ── Sesiones rápidas ──
  ProgramModel(
    id: 'rapido_pecho',
    title: 'Pecho en 40 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.intermedio,
    subtitle: 'Fuerza · Pecho',
    durationMin: 40,
    exerciseCount: 8,
    tags: ['Fuerza', 'Pecho'],
    emoji: '🏋️',
    equipment: 'Gym',
    colorIndex: 0,
    imageUrl: 'https://www.fisioterapiaconmueve.com/wp-content/uploads/2018/04/1.jpg',
    exercises: [
      ProgramExercise(order: 1, name: 'Press banca', sets: 4, reps: 10, weightKg: 60, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/00251301-Barbell-Bench-Press_Chest-FIX_720.gif', notes: 'Agarre medio, bajar a pecho'),
      ProgramExercise(order: 2, name: 'Press inclinado mancuernas', sets: 3, reps: 12, weightKg: 20, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/03241301-Dumbbell-Incline-Palm-in-Press_Chest_720.gif', notes: 'Banco a 30-45°'),
      ProgramExercise(order: 3, name: 'Aperturas con mancuernas', sets: 3, reps: 15, weightKg: 12, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/03081301-Dumbbell-Fly_Chest-FIX_720.gif', notes: 'Codos ligeramente flexionados'),
      ProgramExercise(order: 4, name: 'Cruces en polea alta', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/12701301-Cable-Upper-Chest-Crossovers_Chest_720.gif', notes: 'Contracción al cruzar manos'),
      ProgramExercise(order: 5, name: 'Press declinado', sets: 3, reps: 10, weightKg: 50, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/03031301-Dumbbell-Decline-Hammer-Press_Chest_720.gif'),
      ProgramExercise(order: 6, name: 'Fondos en paralelas', sets: 3, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/02511301-Chest-Dip_Chest_720.gif', notes: 'Inclinarse hacia delante'),
      ProgramExercise(order: 7, name: 'Pull-over con mancuerna', sets: 3, reps: 12, weightKg: 16, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/03751301-Dumbbell-Pullover_Chest_720.gif'),
      ProgramExercise(order: 8, name: 'Flexiones diamante', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/02831301-Diamond-Push-up_Upper-Arms_720.gif', notes: 'Manos juntas bajo el pecho'),
    ],
  ),
  ProgramModel(
    id: 'rapido_pierna',
    title: 'Pierna en 45 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.intermedio,
    subtitle: 'Fuerza · Pierna',
    durationMin: 45,
    exerciseCount: 7,
    tags: ['Fuerza', 'Pierna'],
    emoji: '🦵',
    equipment: 'Gym',
    colorIndex: 1,
    exercises: [
      ProgramExercise(order: 1, name: 'Sentadilla con barra', sets: 4, reps: 10, weightKg: 80, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif', notes: 'Barra alta, profundidad paralela'),
      ProgramExercise(order: 2, name: 'Prensa inclinada', sets: 4, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/07401301-Sled-45%C2%B0-Leg-Wide-Press_Thighs_720.gif', notes: 'Pies separados al ancho de hombros'),
      ProgramExercise(order: 3, name: 'Extensión de cuádriceps', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/05851301-Lever-Leg-Extension_Thighs_720.gif', notes: 'Contracción arriba 2 seg'),
      ProgramExercise(order: 4, name: 'Curl femoral tumbado', sets: 3, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/05991301-Lever-Seated-Leg-Curl_Thighs-FIX_720.gif'),
      ProgramExercise(order: 5, name: 'Zancadas con mancuernas', sets: 3, reps: 12, weightKg: 14, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif', notes: '12 por pierna'),
      ProgramExercise(order: 6, name: 'Elevación de gemelos', sets: 4, reps: 20, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/04171301-Dumbbell-Standing-Calf-Raise_Calf_720.gif', notes: 'Rango completo, pausa abajo'),
      ProgramExercise(order: 7, name: 'Hip thrust', sets: 3, reps: 12, weightKg: 60, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/29641301-Barbell-Glute-Bridge-hands-on-bar_Hips_720.gif', notes: 'Apretar glúteos arriba'),
    ],
  ),
  ProgramModel(
    id: 'rapido_espalda',
    title: 'Espalda en 30 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.intermedio,
    subtitle: 'Fuerza · Espalda',
    durationMin: 30,
    exerciseCount: 6,
    tags: ['Fuerza', 'Espalda'],
    emoji: '🏋️',
    equipment: 'Gym',
    colorIndex: 2,
    exercises: [
      ProgramExercise(order: 1, name: 'Jalón al pecho', sets: 4, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/01981301-Cable-Pulldown_Back_720.gif', notes: 'Agarre prono ancho'),
      ProgramExercise(order: 2, name: 'Remo con barra', sets: 4, reps: 10, weightKg: 50, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00491301-Barbell-Incline-Row_Back_720.gif', notes: 'Espalda a 45°, tirar al ombligo'),
      ProgramExercise(order: 3, name: 'Remo mancuerna a 1 brazo', sets: 3, reps: 12, weightKg: 18, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/02921301-Dumbbell-Bent-over-Row_back_Back_720.gif'),
      ProgramExercise(order: 4, name: 'Pull-over en polea', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/01841301-Cable-Lying-Extension-Pullover-with-rope-attachment_Back_720.gif', notes: 'Brazos extendidos'),
      ProgramExercise(order: 5, name: 'Face pull', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/03801301-Dumbbell-Rear-Lateral-Raise_Shoulders_720.gif', notes: 'Cuerda a la frente, rotación externa'),
      ProgramExercise(order: 6, name: 'Encogimientos con barra', sets: 3, reps: 15, weightKg: 40, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00951301-Barbell-Shrug_Back_720.gif', notes: 'Pausa arriba 2 seg'),
    ],
  ),
  ProgramModel(
    id: 'rapido_core',
    title: 'Core en 10 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.inicio,
    subtitle: 'Core · Sin material',
    durationMin: 10,
    exerciseCount: 6,
    tags: ['Core'],
    emoji: '🔥',
    equipment: 'Sin material',
    colorIndex: 3,
    exercises: [
      ProgramExercise(order: 1, name: 'Plancha frontal', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif', notes: 'Cuerpo recto, no subir cadera'),
      ProgramExercise(order: 2, name: 'Crunch abdominal', sets: 3, reps: 20, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2024/05/43321301-Crunch-Hold_Waist_720.gif'),
      ProgramExercise(order: 3, name: 'Bicicleta', sets: 3, reps: 20, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2024/05/02621301-Cross-Body-Crunch_waist_720.gif', notes: '20 por lado, codo a rodilla'),
      ProgramExercise(order: 4, name: 'Plancha lateral', sets: 2, durationSeconds: 25, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/07151301-Side-Plank-m_Waist_720.gif', notes: '25s por lado'),
      ProgramExercise(order: 5, name: 'Mountain climbers', sets: 3, durationSeconds: 20, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/06301301-Mountain-Climber_Cardio_720.gif', notes: 'Ritmo rápido'),
      ProgramExercise(order: 6, name: 'Elevación de piernas', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2024/05/28021301-Twisted-Leg-Raise_Waist_720.gif', notes: 'Tumbado, no arquear espalda'),
    ],
  ),
  ProgramModel(
    id: 'rapido_biceps',
    title: 'Bíceps en 25 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.intermedio,
    subtitle: 'Brazos · Bíceps',
    durationMin: 25,
    exerciseCount: 6,
    tags: ['Fuerza', 'Brazos', 'Bíceps'],
    emoji: '💪',
    equipment: 'Gym',
    colorIndex: 1,
    exercises: [
      ProgramExercise(order: 1, name: 'Curl con barra', sets: 4, reps: 10, weightKg: 30, restSeconds: 60, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00271301-Barbell-Bent-Over-Row_Back-FIX_720.gif', notes: 'Codos pegados al cuerpo'),
      ProgramExercise(order: 2, name: 'Curl alterno con mancuernas', sets: 3, reps: 12, weightKg: 12, restSeconds: 60, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif', notes: 'Sin balanceo'),
      ProgramExercise(order: 3, name: 'Curl martillo', sets: 3, reps: 12, weightKg: 14, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Trabaja braquial y antebrazo'),
      ProgramExercise(order: 4, name: 'Curl predicador', sets: 3, reps: 10, weightKg: 20, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Banco scott, controlar negativa'),
      ProgramExercise(order: 5, name: 'Curl en polea baja', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Tensión continua'),
      ProgramExercise(order: 6, name: 'Curl concentrado', sets: 3, reps: 12, weightKg: 10, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Pico de contracción'),
    ],
  ),
  ProgramModel(
    id: 'rapido_triceps',
    title: 'Tríceps en 25 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.intermedio,
    subtitle: 'Brazos · Tríceps',
    durationMin: 25,
    exerciseCount: 6,
    tags: ['Fuerza', 'Brazos', 'Tríceps'],
    emoji: '🦾',
    equipment: 'Gym',
    colorIndex: 2,
    exercises: [
      ProgramExercise(order: 1, name: 'Press francés con barra Z', sets: 4, reps: 10, weightKg: 25, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Codos fijos, bajar a la frente'),
      ProgramExercise(order: 2, name: 'Extensión en polea con cuerda', sets: 3, reps: 12, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Separar cuerda al final'),
      ProgramExercise(order: 3, name: 'Fondos en banco', sets: 3, reps: 12, restSeconds: 60, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/02981301-Dumbbell-Bench-Dip_Triceps_720.gif', notes: 'Codos hacia atrás'),
      ProgramExercise(order: 4, name: 'Patada de tríceps', sets: 3, reps: 12, weightKg: 8, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Brazo paralelo al torso'),
      ProgramExercise(order: 5, name: 'Press cerrado con barra', sets: 3, reps: 10, weightKg: 40, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Manos al ancho de hombros'),
      ProgramExercise(order: 6, name: 'Extensión sobre la cabeza', sets: 3, reps: 12, weightKg: 14, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Mancuerna a 2 manos'),
    ],
  ),
  ProgramModel(
    id: 'rapido_hombro',
    title: 'Hombros en 35 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.intermedio,
    subtitle: 'Fuerza · Hombros',
    durationMin: 35,
    exerciseCount: 7,
    tags: ['Fuerza', 'Hombros'],
    emoji: '🏔️',
    equipment: 'Gym',
    colorIndex: 0,
    exercises: [
      ProgramExercise(order: 1, name: 'Press militar con barra', sets: 4, reps: 8, weightKg: 40, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'De pie, glúteos apretados'),
      ProgramExercise(order: 2, name: 'Press Arnold', sets: 3, reps: 10, weightKg: 14, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Rotación al subir'),
      ProgramExercise(order: 3, name: 'Elevaciones laterales', sets: 4, reps: 15, weightKg: 8, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/03801301-Dumbbell-Rear-Lateral-Raise_Shoulders_720.gif', notes: 'Codos ligeramente flexionados'),
      ProgramExercise(order: 4, name: 'Elevaciones frontales', sets: 3, reps: 12, weightKg: 8, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Subir hasta hombro'),
      ProgramExercise(order: 5, name: 'Pájaros (rear delt)', sets: 3, reps: 15, weightKg: 6, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Inclinado, deltoide posterior'),
      ProgramExercise(order: 6, name: 'Face pull', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/36971301-Cable-Kneeling-Rear-Delt-Row-with-rope-male_Shoulder_720.gif', notes: 'Cuerda a la frente'),
      ProgramExercise(order: 7, name: 'Encogimientos con mancuernas', sets: 3, reps: 15, weightKg: 20, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Pausa arriba 2 seg'),
    ],
  ),
  ProgramModel(
    id: 'rapido_gluteos',
    title: 'Glúteos en 30 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.intermedio,
    subtitle: 'Pierna · Glúteos',
    durationMin: 30,
    exerciseCount: 6,
    tags: ['Fuerza', 'Glúteos', 'Pierna'],
    emoji: '🍑',
    equipment: 'Gym',
    colorIndex: 3,
    exercises: [
      ProgramExercise(order: 1, name: 'Hip thrust con barra', sets: 4, reps: 10, weightKg: 70, restSeconds: 60, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/29641301-Barbell-Glute-Bridge-hands-on-bar_Hips_720.gif', notes: 'Bloquear cadera arriba'),
      ProgramExercise(order: 2, name: 'Sentadilla búlgara', sets: 3, reps: 12, weightKg: 14, restSeconds: 60, measurementType: MeasurementType.weight, notes: '12 por pierna, pie atrás en banco'),
      ProgramExercise(order: 3, name: 'Peso muerto sumo', sets: 3, reps: 10, weightKg: 60, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Pies anchos, punteras afuera'),
      ProgramExercise(order: 4, name: 'Patada de glúteo en polea', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Apretar glúteo arriba'),
      ProgramExercise(order: 5, name: 'Abducción en máquina', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Inclinarse adelante para enfocar glúteo'),
      ProgramExercise(order: 6, name: 'Puente de glúteo con banda', sets: 3, reps: 20, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Banda sobre rodillas, abrir al subir'),
    ],
  ),
  ProgramModel(
    id: 'rapido_abs',
    title: 'Abs completos en 20 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.intermedio,
    subtitle: 'Core · Abdominales',
    durationMin: 20,
    exerciseCount: 7,
    tags: ['Core', 'Abdominales'],
    emoji: '🔥',
    equipment: 'Sin material',
    colorIndex: 4,
    exercises: [
      ProgramExercise(order: 1, name: 'Crunch abdominal', sets: 3, reps: 20, restSeconds: 30, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2024/05/43321301-Crunch-Hold_Waist_720.gif'),
      ProgramExercise(order: 2, name: 'Elevación de piernas colgado', sets: 3, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'O en silla romana'),
      ProgramExercise(order: 3, name: 'Plancha frontal', sets: 3, durationSeconds: 45, restSeconds: 30, measurementType: MeasurementType.time, notes: 'Cuerpo recto'),
      ProgramExercise(order: 4, name: 'Russian twist', sets: 3, reps: 20, weightKg: 5, restSeconds: 30, measurementType: MeasurementType.weight, notes: '20 toques (10 por lado)'),
      ProgramExercise(order: 5, name: 'Plancha lateral', sets: 3, durationSeconds: 30, restSeconds: 30, measurementType: MeasurementType.time, notes: '30s por lado'),
      ProgramExercise(order: 6, name: 'Tijeras de pierna', sets: 3, reps: 20, restSeconds: 30, measurementType: MeasurementType.reps, notes: 'Tumbado, alternar piernas'),
      ProgramExercise(order: 7, name: 'Hollow hold', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2024/05/12461301-Hollow-Hold_Waist_720.gif'),
    ],
  ),
  ProgramModel(
    id: 'rapido_brazos',
    title: 'Brazos en 30 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.intermedio,
    subtitle: 'Bíceps + Tríceps superserie',
    durationMin: 30,
    exerciseCount: 6,
    tags: ['Fuerza', 'Brazos', 'Bíceps', 'Tríceps'],
    emoji: '💪',
    equipment: 'Gym',
    colorIndex: 5,
    exercises: [
      ProgramExercise(order: 1, name: 'Curl con barra', sets: 4, reps: 10, weightKg: 30, restSeconds: 30, measurementType: MeasurementType.weight, notes: 'Superserie con press francés'),
      ProgramExercise(order: 2, name: 'Press francés', sets: 4, reps: 10, weightKg: 25, restSeconds: 60, measurementType: MeasurementType.weight),
      ProgramExercise(order: 3, name: 'Curl martillo', sets: 3, reps: 12, weightKg: 14, restSeconds: 30, measurementType: MeasurementType.weight, notes: 'Superserie con extensión polea'),
      ProgramExercise(order: 4, name: 'Extensión en polea', sets: 3, reps: 15, restSeconds: 60, measurementType: MeasurementType.reps),
      ProgramExercise(order: 5, name: 'Curl predicador', sets: 3, reps: 12, weightKg: 18, restSeconds: 30, measurementType: MeasurementType.weight, notes: 'Superserie con fondos en banco'),
      ProgramExercise(order: 6, name: 'Fondos en banco', sets: 3, reps: 15, restSeconds: 60, measurementType: MeasurementType.reps),
    ],
  ),
  ProgramModel(
    id: 'rapido_pantorrillas',
    title: 'Pantorrillas en 15 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.todos,
    subtitle: 'Pierna · Gemelos',
    durationMin: 15,
    exerciseCount: 4,
    tags: ['Fuerza', 'Pierna'],
    emoji: '🦵',
    equipment: 'Gym',
    colorIndex: 0,
    exercises: [
      ProgramExercise(order: 1, name: 'Gemelo de pie en máquina', sets: 4, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/04171301-Dumbbell-Standing-Calf-Raise_Calf_720.gif', notes: 'Pausa arriba 2 seg'),
      ProgramExercise(order: 2, name: 'Gemelo sentado', sets: 4, reps: 20, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Trabaja sóleo'),
      ProgramExercise(order: 3, name: 'Gemelo en prensa', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Empujar con punta de pie'),
      ProgramExercise(order: 4, name: 'Gemelos a 1 pierna con mancuerna', sets: 3, reps: 12, weightKg: 16, restSeconds: 45, measurementType: MeasurementType.weight, notes: '12 por pierna'),
    ],
  ),
  ProgramModel(
    id: 'rapido_antebrazos',
    title: 'Antebrazos y agarre',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.todos,
    subtitle: 'Antebrazos · Agarre',
    durationMin: 15,
    exerciseCount: 5,
    tags: ['Fuerza', 'Brazos'],
    emoji: '✊',
    equipment: 'Gym',
    colorIndex: 2,
    exercises: [
      ProgramExercise(order: 1, name: 'Curl de muñeca con barra', sets: 4, reps: 15, weightKg: 15, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Antebrazos sobre banco'),
      ProgramExercise(order: 2, name: 'Curl de muñeca inverso', sets: 3, reps: 15, weightKg: 10, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Palmas hacia abajo'),
      ProgramExercise(order: 3, name: 'Farmer carry', sets: 3, durationSeconds: 30, restSeconds: 60, measurementType: MeasurementType.time, notes: 'Caminar con mancuernas pesadas'),
      ProgramExercise(order: 4, name: 'Dead hang', sets: 3, durationSeconds: 30, restSeconds: 60, measurementType: MeasurementType.time, notes: 'Colgarse de barra'),
      ProgramExercise(order: 5, name: 'Curl tipo Zottman', sets: 3, reps: 12, weightKg: 12, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Subir supinado, bajar pronado'),
    ],
  ),
  ProgramModel(
    id: 'rapido_lumbar',
    title: 'Lumbar y core posterior',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.todos,
    subtitle: 'Espalda baja · Core',
    durationMin: 20,
    exerciseCount: 6,
    tags: ['Espalda', 'Core'],
    emoji: '🛡️',
    equipment: 'Sin material',
    colorIndex: 1,
    exercises: [
      ProgramExercise(order: 1, name: 'Hiperextensión', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Banco romano o GHD'),
      ProgramExercise(order: 2, name: 'Superman', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Brazos y piernas elevados'),
      ProgramExercise(order: 3, name: 'Bird dog', sets: 3, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, notes: '12 por lado, control'),
      ProgramExercise(order: 4, name: 'Good morning con barra', sets: 3, reps: 12, weightKg: 30, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Cadera atrás, espalda recta'),
      ProgramExercise(order: 5, name: 'Plancha invertida', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Cadera arriba, glúteos apretados'),
      ProgramExercise(order: 6, name: 'Dead bug', sets: 3, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, notes: '12 por lado'),
    ],
  ),
  ProgramModel(
    id: 'rapido_fullbody_casa',
    title: 'Full body en casa 20 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.inicio,
    subtitle: 'Sin material · Cuerpo completo',
    durationMin: 20,
    exerciseCount: 7,
    tags: ['Calistenia', 'HIIT'],
    emoji: '🏠',
    equipment: 'Sin material',
    colorIndex: 5,
    exercises: [
      ProgramExercise(order: 1, name: 'Sentadilla', sets: 3, reps: 15, restSeconds: 30, measurementType: MeasurementType.reps),
      ProgramExercise(order: 2, name: 'Flexiones', sets: 3, reps: 12, restSeconds: 30, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/06621301-Push-up-m_Chest-FIX_720.gif'),
      ProgramExercise(order: 3, name: 'Zancadas', sets: 3, reps: 12, restSeconds: 30, measurementType: MeasurementType.reps, notes: '12 por pierna'),
      ProgramExercise(order: 4, name: 'Remo invertido', sets: 3, reps: 10, restSeconds: 30, measurementType: MeasurementType.reps, notes: 'Bajo una mesa o barra'),
      ProgramExercise(order: 5, name: 'Plancha', sets: 3, durationSeconds: 30, restSeconds: 30, measurementType: MeasurementType.time),
      ProgramExercise(order: 6, name: 'Mountain climbers', sets: 3, durationSeconds: 30, restSeconds: 30, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/06301301-Mountain-Climber_Cardio_720.gif'),
      ProgramExercise(order: 7, name: 'Burpees', sets: 3, reps: 8, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/11601301-Burpee_Cardio_720.gif'),
    ],
  ),
  ProgramModel(
    id: 'rapido_hiit',
    title: 'HIIT en 15 min',
    category: ProgramCategory.rapidos,
    level: ProgramLevel.intermedio,
    subtitle: 'Alta intensidad · Sin material',
    durationMin: 15,
    exerciseCount: 8,
    tags: ['HIIT'],
    emoji: '⚡',
    equipment: 'Sin material',
    colorIndex: 4,
    exercises: [
      ProgramExercise(order: 1, name: 'Burpees', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/11601301-Burpee_Cardio_720.gif', notes: '30s trabajo / 15s descanso'),
      ProgramExercise(order: 2, name: 'Mountain climbers', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/06301301-Mountain-Climber_Cardio_720.gif'),
      ProgramExercise(order: 3, name: 'Saltos de estrella', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/30941301-Jumping-Jack-male_Cardio_720.gif'),
      ProgramExercise(order: 4, name: 'Sentadilla con salto', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/15521301-Dumbbell-Jumping-Squat_Plyometric_720.gif'),
      ProgramExercise(order: 5, name: 'Skaters laterales', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/30941301-Jumping-Jack-male_Cardio_720.gif'),
      ProgramExercise(order: 6, name: 'Rodillas altas', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/31991301-Skips_Cardio_720.gif', notes: 'Ritmo máximo'),
      ProgramExercise(order: 7, name: 'Flexiones explosivas', sets: 3, reps: 10, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/06621301-Push-up-m_Chest-FIX_720.gif'),
      ProgramExercise(order: 8, name: 'Plancha con toque de hombro', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Alternar manos sin rotar cadera'),
    ],
  ),

  // ── Programas progresivos ──
  ProgramModel(
    id: 'rino_pierna_hombro',
    title: 'Rino Pierna y Hombro',
    category: ProgramCategory.programas,
    level: ProgramLevel.intermedio,
    subtitle: 'Fuerza · Pierna',
    durationMin: 75,
    exerciseCount: 17,
    tags: ['Pierna', 'Hombro', 'Fuerza'],
    emoji: '🦏',
    equipment: 'Gym',
    colorIndex: 1,
    exercises: [
      // ── Fase Calentamiento ──
      ProgramExercise(order: 1, name: 'Correr', sets: 1, durationSeconds: 600, restSeconds: 0, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/06841301-Run-equipment_Cardio_720.gif', notes: 'Cinta 10 min · Calentamiento'),
      // ── Fase Movilidad ──
      ProgramExercise(order: 2, name: 'Círculos de cadera', sets: 2, reps: 15, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Movilidad · 15 por sentido'),
      ProgramExercise(order: 3, name: 'Balanceo de pierna', sets: 2, reps: 15, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Movilidad · 15 por pierna'),
      ProgramExercise(order: 4, name: 'Sentadilla lateral profunda', sets: 2, reps: 15, restSeconds: 0, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/34481301-Dumbbell-Side-Lunge-VERSION-3_720.gif', notes: 'Movilidad · Sin peso'),
      ProgramExercise(order: 5, name: 'Kneeling Hip Flexor Stretch', sets: 2, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Movilidad · 30s por lado'),
      ProgramExercise(order: 6, name: 'Meada de perro', sets: 2, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Movilidad · 10 por pierna'),
      // ── Fase Ejercicios ──
      ProgramExercise(order: 7, name: 'Sentadilla con barra', sets: 4, reps: 10, weightKg: 80, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif', notes: 'Barra alta, profundidad paralela'),
      ProgramExercise(order: 8, name: 'Peso muerto rumano', sets: 4, reps: 10, weightKg: 60, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00851301-Barbell-Romanian-Deadlift_Hips_720.gif', notes: 'Con barra, rodillas ligeramente flexionadas'),
      ProgramExercise(order: 9, name: 'Prensa de piernas', sets: 4, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/07401301-Sled-45%C2%B0-Leg-Wide-Press_Thighs_720.gif', notes: 'Pies al ancho de hombros'),
      ProgramExercise(order: 10, name: 'Curl femoral acostado', sets: 3, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/05861301-Lever-Lying-Leg-Curl_Thighs_720.gif', notes: 'Máquina tumbado'),
      ProgramExercise(order: 11, name: 'Zancadas caminando', sets: 3, reps: 12, weightKg: 14, restSeconds: 45, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/03361301-Dumbbell-Lunge_Hips_720.gif', notes: 'Con mancuernas, 12 por pierna'),
      ProgramExercise(order: 12, name: 'Extensión de cuádriceps', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/05851301-Lever-Leg-Extension_Thighs_720.gif', notes: 'Contracción arriba 2 seg'),
      ProgramExercise(order: 13, name: 'Press de pantorrilla', sets: 4, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/13831301-Hack-Calf-Raise_Calves_720.gif', notes: 'Máquina, rango completo'),
    ],
  ),

  ProgramModel(
    id: 'gorila_tiron',
    title: 'Fuerza de tirón',
    category: ProgramCategory.programas,
    level: ProgramLevel.intermedio,
    subtitle: 'Espalda · Bíceps · Core',
    durationMin: 70,
    exerciseCount: 18,
    tags: ['Espalda', 'Bíceps', 'Core', 'Tirón'],
    emoji: '🦍',
    equipment: 'Gym',
    colorIndex: 3,
    description: 'Desarrollar fuerza de tirón, densidad en la espalda, estabilidad escapular y activación del core.',
    exercises: [
      // ── Calentamiento ──
      ProgramExercise(order: 1, name: 'Caminar rápido en cinta', sets: 1, durationSeconds: 300, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Calentamiento · 5 min'),
      // ── Movilidad ──
      ProgramExercise(order: 2, name: 'Cat-cow', sets: 1, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Movilidad dorsal'),
      ProgramExercise(order: 3, name: 'Thread the needle', sets: 1, reps: 8, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Movilidad · 8 por lado'),
      ProgramExercise(order: 4, name: 'Open book', sets: 1, reps: 8, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Movilidad · 8 por lado'),
      ProgramExercise(order: 5, name: 'Dead hang', sets: 1, durationSeconds: 25, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Movilidad · Colgarse pasivo 20-30 seg'),
      ProgramExercise(order: 6, name: 'Band pull-aparts', sets: 1, reps: 15, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Activación escapular'),
      ProgramExercise(order: 7, name: 'Dead bug', sets: 1, reps: 8, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Activación core · 8 por lado'),
      // ── Fuerza ──
      ProgramExercise(order: 8, name: 'Dominadas o jalón', sets: 4, reps: 8, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/14291301-Wide-Grip-Pull-Up_Back_720.gif', notes: '4 × 6–10 reps'),
      ProgramExercise(order: 9, name: 'Remo barra o máquina', sets: 3, reps: 9, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00271301-Barbell-Bent-Over-Row_Back-FIX_720.gif', notes: '3 × 8–10 reps'),
      ProgramExercise(order: 10, name: 'Remo unilateral', sets: 3, reps: 10, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/02921301-Dumbbell-Bent-over-Row_back_Back_720.gif', notes: '3 × 10 reps por brazo'),
      ProgramExercise(order: 11, name: 'Face pull', sets: 3, reps: 13, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/36971301-Cable-Kneeling-Rear-Delt-Row-with-rope-male_Shoulder_720.gif', notes: '3 × 12–15 reps'),
      ProgramExercise(order: 12, name: 'Curl bíceps', sets: 3, reps: 11, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/02851301-Dumbbell-Alternate-Biceps-Curl_Upper-Arms_720.gif', notes: '3 × 10–12 reps'),
      // ── Core ──
      ProgramExercise(order: 13, name: 'Dead bug', sets: 3, reps: 11, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Core · 3 × 10–12 reps'),
      ProgramExercise(order: 14, name: 'Hollow hold', sets: 3, durationSeconds: 25, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2024/05/12461301-Hollow-Hold_Waist_720.gif', notes: 'Core · 3 × 20–30 seg'),
      // ── Vuelta a la calma ──
      ProgramExercise(order: 15, name: 'Child\'s pose lateral', sets: 1, durationSeconds: 20, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Vuelta a la calma · 20 seg por lado'),
      ProgramExercise(order: 16, name: 'Open book', sets: 1, reps: 6, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Vuelta a la calma · 6 por lado'),
      ProgramExercise(order: 17, name: 'Estiramiento de bíceps en pared', sets: 1, durationSeconds: 20, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Vuelta a la calma · 20 seg por lado'),
    ],
  ),

  ProgramModel(
    id: 'prog_running_inicio',
    title: 'Running inicio',
    category: ProgramCategory.programas,
    level: ProgramLevel.inicio,
    subtitle: 'De cero a correr 20 min',
    weeks: 4,
    daysPerWeek: 3,
    tags: ['Running', 'Cardio'],
    emoji: '🏃',
    colorIndex: 5,
    exercises: [
      ProgramExercise(order: 1, name: 'Caminar rápido', sets: 1, durationSeconds: 300, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Calentamiento 5 min'),
      ProgramExercise(order: 2, name: 'Trote suave', sets: 4, durationSeconds: 60, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Sem 1: 1 min trote / 2 min andar'),
      ProgramExercise(order: 3, name: 'Carrera continua', sets: 1, durationSeconds: 600, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Sem 4: 10 min sin parar'),
      ProgramExercise(order: 4, name: 'Vuelta a la calma', sets: 1, durationSeconds: 300, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Caminar 5 min + estiramientos'),
    ],
  ),
  ProgramModel(
    id: 'prog_running_avanzado',
    title: 'Running avanzado',
    category: ProgramCategory.programas,
    level: ProgramLevel.avanzado,
    subtitle: 'Mejora tu ritmo y distancia',
    weeks: 6,
    daysPerWeek: 4,
    tags: ['Running', 'Cardio'],
    emoji: '🏃',
    colorIndex: 0,
    exercises: [
      ProgramExercise(order: 1, name: 'Carrera continua', sets: 1, durationSeconds: 1800, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Día 1: 30 min ritmo base'),
      ProgramExercise(order: 2, name: 'Series 400m', sets: 6, distanceMeters: 400, restSeconds: 45, measurementType: MeasurementType.distance, notes: 'Día 2: ritmo fuerte, descanso trotando'),
      ProgramExercise(order: 3, name: 'Fartlek', sets: 1, durationSeconds: 2400, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Día 3: 40 min alternar ritmos'),
      ProgramExercise(order: 4, name: 'Tirada larga', sets: 1, distanceMeters: 10000, restSeconds: 0, measurementType: MeasurementType.distance, notes: 'Día 4: 10 km ritmo cómodo'),
    ],
  ),
  ProgramModel(
    id: 'prog_calistenia_inicio',
    title: 'Calistenia inicio',
    category: ProgramCategory.programas,
    level: ProgramLevel.inicio,
    subtitle: 'Técnica + fuerza corporal',
    weeks: 6,
    daysPerWeek: 3,
    tags: ['Calistenia'],
    emoji: '🤸',
    colorIndex: 1,
    exercises: [
      ProgramExercise(order: 1, name: 'Dominadas asistidas', sets: 3, reps: 5, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/06271301-Mixed-Grip-Chin-up_back_720.gif', notes: 'Banda elástica o negativas'),
      ProgramExercise(order: 2, name: 'Fondos en paralelas', sets: 3, reps: 8, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/02511301-Chest-Dip_Chest_720.gif', notes: 'Rango completo'),
      ProgramExercise(order: 3, name: 'Flexiones', sets: 3, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/06621301-Push-up-m_Chest-FIX_720.gif'),
      ProgramExercise(order: 4, name: 'Sentadilla pistol asistida', sets: 3, reps: 5, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif', notes: 'Sujetarse a TRX o poste'),
      ProgramExercise(order: 5, name: 'L-sit en paralelas', sets: 3, durationSeconds: 10, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Piernas dobladas si necesario'),
      ProgramExercise(order: 6, name: 'Plancha frontal', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time),
    ],
  ),
  ProgramModel(
    id: 'prog_ppl',
    title: 'Push Pull Legs',
    category: ProgramCategory.programas,
    level: ProgramLevel.intermedio,
    subtitle: 'Empuje · Tirón · Pierna',
    weeks: 8,
    daysPerWeek: 6,
    exerciseCount: 18,
    tags: ['Fuerza', 'Push', 'Pull', 'Pierna'],
    emoji: '🔄',
    equipment: 'Gym',
    colorIndex: 0,
    description: 'División clásica para hipertrofia: 3 días distintos repetidos 2 veces por semana.',
    exercises: [
      // ── Día PUSH (Pecho/Hombro/Tríceps) ──
      ProgramExercise(order: 1, name: 'Push · Press banca', sets: 4, reps: 8, weightKg: 70, restSeconds: 90, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/00251301-Barbell-Bench-Press_Chest-FIX_720.gif', notes: 'Día 1'),
      ProgramExercise(order: 2, name: 'Push · Press militar', sets: 4, reps: 8, weightKg: 40, restSeconds: 90, measurementType: MeasurementType.weight, notes: 'Día 1'),
      ProgramExercise(order: 3, name: 'Push · Press inclinado mancuernas', sets: 3, reps: 10, weightKg: 22, restSeconds: 75, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/03241301-Dumbbell-Incline-Palm-in-Press_Chest_720.gif', notes: 'Día 1'),
      ProgramExercise(order: 4, name: 'Push · Elevaciones laterales', sets: 4, reps: 12, weightKg: 8, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Día 1'),
      ProgramExercise(order: 5, name: 'Push · Press francés', sets: 3, reps: 10, weightKg: 25, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Día 1'),
      ProgramExercise(order: 6, name: 'Push · Extensión polea', sets: 3, reps: 12, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Día 1'),
      // ── Día PULL (Espalda/Bíceps/Posterior) ──
      ProgramExercise(order: 7, name: 'Pull · Dominadas o jalón', sets: 4, reps: 8, restSeconds: 90, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/14291301-Wide-Grip-Pull-Up_Back_720.gif', notes: 'Día 2'),
      ProgramExercise(order: 8, name: 'Pull · Remo con barra', sets: 4, reps: 8, weightKg: 60, restSeconds: 90, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00271301-Barbell-Bent-Over-Row_Back-FIX_720.gif', notes: 'Día 2'),
      ProgramExercise(order: 9, name: 'Pull · Remo mancuerna', sets: 3, reps: 10, weightKg: 22, restSeconds: 75, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/02921301-Dumbbell-Bent-over-Row_back_Back_720.gif', notes: 'Día 2'),
      ProgramExercise(order: 10, name: 'Pull · Face pull', sets: 4, reps: 15, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Día 2'),
      ProgramExercise(order: 11, name: 'Pull · Curl barra', sets: 3, reps: 10, weightKg: 30, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Día 2'),
      ProgramExercise(order: 12, name: 'Pull · Curl martillo', sets: 3, reps: 12, weightKg: 14, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Día 2'),
      // ── Día LEGS ──
      ProgramExercise(order: 13, name: 'Legs · Sentadilla con barra', sets: 4, reps: 8, weightKg: 90, restSeconds: 120, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00631301-Barbell-Narrow-Stance-Squat_Thighs_720.gif', notes: 'Día 3'),
      ProgramExercise(order: 14, name: 'Legs · Peso muerto rumano', sets: 4, reps: 10, weightKg: 70, restSeconds: 90, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/00851301-Barbell-Romanian-Deadlift_Hips_720.gif', notes: 'Día 3'),
      ProgramExercise(order: 15, name: 'Legs · Prensa', sets: 3, reps: 12, restSeconds: 75, measurementType: MeasurementType.reps, notes: 'Día 3'),
      ProgramExercise(order: 16, name: 'Legs · Curl femoral', sets: 3, reps: 12, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Día 3'),
      ProgramExercise(order: 17, name: 'Legs · Hip thrust', sets: 3, reps: 10, weightKg: 60, restSeconds: 75, measurementType: MeasurementType.weight, notes: 'Día 3'),
      ProgramExercise(order: 18, name: 'Legs · Gemelos de pie', sets: 4, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Día 3'),
    ],
  ),
  ProgramModel(
    id: 'prog_upper_lower',
    title: 'Upper / Lower',
    category: ProgramCategory.programas,
    level: ProgramLevel.intermedio,
    subtitle: 'Tren superior + inferior',
    weeks: 6,
    daysPerWeek: 4,
    exerciseCount: 14,
    tags: ['Fuerza'],
    emoji: '⚖️',
    equipment: 'Gym',
    colorIndex: 2,
    description: 'Alterna 2 días tren superior y 2 días tren inferior para volumen y frecuencia.',
    exercises: [
      // UPPER A
      ProgramExercise(order: 1, name: 'Upper · Press banca', sets: 4, reps: 8, weightKg: 70, restSeconds: 90, measurementType: MeasurementType.weight, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/00251301-Barbell-Bench-Press_Chest-FIX_720.gif', notes: 'Día Upper'),
      ProgramExercise(order: 2, name: 'Upper · Remo con barra', sets: 4, reps: 8, weightKg: 60, restSeconds: 90, measurementType: MeasurementType.weight, notes: 'Día Upper'),
      ProgramExercise(order: 3, name: 'Upper · Press militar mancuernas', sets: 3, reps: 10, weightKg: 18, restSeconds: 75, measurementType: MeasurementType.weight, notes: 'Día Upper'),
      ProgramExercise(order: 4, name: 'Upper · Jalón al pecho', sets: 3, reps: 10, restSeconds: 75, measurementType: MeasurementType.reps, notes: 'Día Upper'),
      ProgramExercise(order: 5, name: 'Upper · Curl alterno', sets: 3, reps: 12, weightKg: 12, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Día Upper'),
      ProgramExercise(order: 6, name: 'Upper · Press francés', sets: 3, reps: 10, weightKg: 25, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Día Upper'),
      ProgramExercise(order: 7, name: 'Upper · Plancha', sets: 3, durationSeconds: 45, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Día Upper'),
      // LOWER
      ProgramExercise(order: 8, name: 'Lower · Sentadilla', sets: 4, reps: 8, weightKg: 90, restSeconds: 120, measurementType: MeasurementType.weight, notes: 'Día Lower'),
      ProgramExercise(order: 9, name: 'Lower · Peso muerto rumano', sets: 4, reps: 10, weightKg: 70, restSeconds: 90, measurementType: MeasurementType.weight, notes: 'Día Lower'),
      ProgramExercise(order: 10, name: 'Lower · Zancada con barra', sets: 3, reps: 10, weightKg: 40, restSeconds: 75, measurementType: MeasurementType.weight, notes: '10 por pierna · Día Lower'),
      ProgramExercise(order: 11, name: 'Lower · Extensión cuádriceps', sets: 3, reps: 12, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Día Lower'),
      ProgramExercise(order: 12, name: 'Lower · Curl femoral', sets: 3, reps: 12, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Día Lower'),
      ProgramExercise(order: 13, name: 'Lower · Hip thrust', sets: 3, reps: 12, weightKg: 60, restSeconds: 75, measurementType: MeasurementType.weight, notes: 'Día Lower'),
      ProgramExercise(order: 14, name: 'Lower · Gemelos', sets: 4, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Día Lower'),
    ],
  ),
  ProgramModel(
    id: 'prog_full_body_inicio',
    title: 'Full Body principiante',
    category: ProgramCategory.programas,
    level: ProgramLevel.inicio,
    subtitle: 'Cuerpo completo · 3 días',
    weeks: 6,
    daysPerWeek: 3,
    exerciseCount: 8,
    tags: ['Fuerza'],
    emoji: '🌱',
    equipment: 'Gym',
    colorIndex: 5,
    description: 'Programa de iniciación para construir base de fuerza y técnica.',
    exercises: [
      ProgramExercise(order: 1, name: 'Sentadilla con barra', sets: 3, reps: 10, weightKg: 40, restSeconds: 90, measurementType: MeasurementType.weight, notes: 'Aprende técnica primero'),
      ProgramExercise(order: 2, name: 'Press banca', sets: 3, reps: 10, weightKg: 30, restSeconds: 90, measurementType: MeasurementType.weight),
      ProgramExercise(order: 3, name: 'Remo en máquina', sets: 3, reps: 12, restSeconds: 75, measurementType: MeasurementType.reps),
      ProgramExercise(order: 4, name: 'Press militar mancuernas', sets: 3, reps: 12, weightKg: 10, restSeconds: 75, measurementType: MeasurementType.weight),
      ProgramExercise(order: 5, name: 'Jalón al pecho', sets: 3, reps: 12, restSeconds: 75, measurementType: MeasurementType.reps),
      ProgramExercise(order: 6, name: 'Curl con mancuernas', sets: 3, reps: 12, weightKg: 8, restSeconds: 45, measurementType: MeasurementType.weight),
      ProgramExercise(order: 7, name: 'Extensión tríceps polea', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps),
      ProgramExercise(order: 8, name: 'Plancha', sets: 3, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time),
    ],
  ),
  ProgramModel(
    id: 'prog_volumen_pecho',
    title: 'Volumen pecho 4 semanas',
    category: ProgramCategory.programas,
    level: ProgramLevel.avanzado,
    subtitle: 'Hipertrofia · Pecho',
    weeks: 4,
    daysPerWeek: 2,
    exerciseCount: 8,
    tags: ['Fuerza', 'Pecho'],
    emoji: '🏋️',
    equipment: 'Gym',
    colorIndex: 3,
    description: 'Especialización para ganar masa pectoral. Combina con tu rutina semanal.',
    exercises: [
      ProgramExercise(order: 1, name: 'Press banca plano', sets: 5, reps: 6, weightKg: 75, restSeconds: 120, measurementType: MeasurementType.weight, notes: 'Carga pesada, 5×6'),
      ProgramExercise(order: 2, name: 'Press inclinado barra', sets: 4, reps: 8, weightKg: 55, restSeconds: 90, measurementType: MeasurementType.weight, notes: 'Banco a 30°'),
      ProgramExercise(order: 3, name: 'Press declinado mancuernas', sets: 3, reps: 10, weightKg: 24, restSeconds: 75, measurementType: MeasurementType.weight),
      ProgramExercise(order: 4, name: 'Aperturas en banco inclinado', sets: 3, reps: 12, weightKg: 12, restSeconds: 60, measurementType: MeasurementType.weight),
      ProgramExercise(order: 5, name: 'Cruce en polea baja', sets: 3, reps: 15, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Foco pecho superior'),
      ProgramExercise(order: 6, name: 'Cruce en polea alta', sets: 3, reps: 15, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Foco pecho inferior'),
      ProgramExercise(order: 7, name: 'Fondos en paralelas lastrados', sets: 3, reps: 8, weightKg: 10, restSeconds: 75, measurementType: MeasurementType.weight, notes: 'Inclinarse adelante'),
      ProgramExercise(order: 8, name: 'Push-up burnout', sets: 2, reps: 25, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Al fallo'),
    ],
  ),
  ProgramModel(
    id: 'prog_volumen_espalda',
    title: 'Volumen espalda 4 semanas',
    category: ProgramCategory.programas,
    level: ProgramLevel.avanzado,
    subtitle: 'Hipertrofia · Espalda',
    weeks: 4,
    daysPerWeek: 2,
    exerciseCount: 8,
    tags: ['Fuerza', 'Espalda'],
    emoji: '🐉',
    equipment: 'Gym',
    colorIndex: 1,
    description: 'Construye anchura y densidad en la espalda. Foco dorsal y trapecio medio.',
    exercises: [
      ProgramExercise(order: 1, name: 'Peso muerto convencional', sets: 5, reps: 5, weightKg: 100, restSeconds: 180, measurementType: MeasurementType.weight, notes: '5×5 carga máxima controlada'),
      ProgramExercise(order: 2, name: 'Dominadas lastradas', sets: 4, reps: 8, weightKg: 10, restSeconds: 120, measurementType: MeasurementType.weight, notes: 'Si no salen, asistidas'),
      ProgramExercise(order: 3, name: 'Remo Pendlay', sets: 4, reps: 8, weightKg: 60, restSeconds: 90, measurementType: MeasurementType.weight, notes: 'Barra al suelo entre reps'),
      ProgramExercise(order: 4, name: 'Remo en T', sets: 3, reps: 10, weightKg: 40, restSeconds: 75, measurementType: MeasurementType.weight),
      ProgramExercise(order: 5, name: 'Jalón agarre neutro', sets: 3, reps: 12, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Foco dorsal bajo'),
      ProgramExercise(order: 6, name: 'Pull-over en polea', sets: 3, reps: 15, restSeconds: 60, measurementType: MeasurementType.reps),
      ProgramExercise(order: 7, name: 'Encogimientos pesados', sets: 4, reps: 12, weightKg: 50, restSeconds: 60, measurementType: MeasurementType.weight, notes: 'Trapecio'),
      ProgramExercise(order: 8, name: 'Hiperextensión', sets: 3, reps: 15, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Lumbar'),
    ],
  ),
  ProgramModel(
    id: 'prog_brazos_21',
    title: 'Brazos en 21 días',
    category: ProgramCategory.programas,
    level: ProgramLevel.intermedio,
    subtitle: 'Bíceps + Tríceps',
    weeks: 3,
    daysPerWeek: 3,
    exerciseCount: 10,
    tags: ['Fuerza', 'Brazos', 'Bíceps', 'Tríceps'],
    emoji: '💪',
    equipment: 'Gym',
    colorIndex: 4,
    description: 'Especialización corta para ganar centímetros de brazo en 3 semanas.',
    exercises: [
      ProgramExercise(order: 1, name: 'Curl 21s con barra', sets: 3, reps: 21, weightKg: 20, restSeconds: 75, measurementType: MeasurementType.weight, notes: '7 medio bajo + 7 medio alto + 7 completos'),
      ProgramExercise(order: 2, name: 'Press cerrado banca', sets: 4, reps: 8, weightKg: 50, restSeconds: 90, measurementType: MeasurementType.weight, notes: 'Codos pegados al cuerpo'),
      ProgramExercise(order: 3, name: 'Curl predicador', sets: 4, reps: 10, weightKg: 20, restSeconds: 60, measurementType: MeasurementType.weight),
      ProgramExercise(order: 4, name: 'Press francés acostado', sets: 4, reps: 10, weightKg: 25, restSeconds: 60, measurementType: MeasurementType.weight),
      ProgramExercise(order: 5, name: 'Curl martillo cruzado', sets: 3, reps: 12, weightKg: 14, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Mano al hombro contrario'),
      ProgramExercise(order: 6, name: 'Patada de tríceps', sets: 3, reps: 12, weightKg: 8, restSeconds: 45, measurementType: MeasurementType.weight),
      ProgramExercise(order: 7, name: 'Curl cable barra recta', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps),
      ProgramExercise(order: 8, name: 'Extensión polea cuerda', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps),
      ProgramExercise(order: 9, name: 'Curl Zottman', sets: 3, reps: 10, weightKg: 12, restSeconds: 45, measurementType: MeasurementType.weight),
      ProgramExercise(order: 10, name: 'Fondos en paralelas', sets: 3, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps),
    ],
  ),
  ProgramModel(
    id: 'prog_gluteos_30dias',
    title: 'Glúteos 30 días',
    category: ProgramCategory.programas,
    level: ProgramLevel.intermedio,
    subtitle: 'Glúteos · Hipertrofia',
    weeks: 4,
    daysPerWeek: 3,
    exerciseCount: 9,
    tags: ['Glúteos', 'Pierna', 'Fuerza'],
    emoji: '🍑',
    equipment: 'Gym',
    colorIndex: 3,
    description: 'Reto de 30 días para volumen y forma de glúteo. Combinar con dieta superávit.',
    exercises: [
      ProgramExercise(order: 1, name: 'Hip thrust con barra', sets: 5, reps: 10, weightKg: 80, restSeconds: 90, measurementType: MeasurementType.weight, notes: 'Movimiento principal'),
      ProgramExercise(order: 2, name: 'Sentadilla búlgara con mancuernas', sets: 4, reps: 10, weightKg: 16, restSeconds: 75, measurementType: MeasurementType.weight, notes: '10 por pierna'),
      ProgramExercise(order: 3, name: 'Peso muerto sumo', sets: 4, reps: 8, weightKg: 70, restSeconds: 90, measurementType: MeasurementType.weight),
      ProgramExercise(order: 4, name: 'Patada de glúteo polea', sets: 3, reps: 15, restSeconds: 60, measurementType: MeasurementType.reps, notes: '15 por pierna'),
      ProgramExercise(order: 5, name: 'Abducción de cadera', sets: 4, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps),
      ProgramExercise(order: 6, name: 'Step-up con mancuernas', sets: 3, reps: 12, weightKg: 14, restSeconds: 60, measurementType: MeasurementType.weight, notes: '12 por pierna'),
      ProgramExercise(order: 7, name: 'Buenos días con barra', sets: 3, reps: 12, weightKg: 30, restSeconds: 60, measurementType: MeasurementType.weight),
      ProgramExercise(order: 8, name: 'Puente con banda', sets: 3, reps: 20, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Banda sobre rodillas'),
      ProgramExercise(order: 9, name: 'Plancha lateral con elevación pierna', sets: 3, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, notes: '12 por lado'),
    ],
  ),
  ProgramModel(
    id: 'prog_core_6sem',
    title: 'Core de acero 6 semanas',
    category: ProgramCategory.programas,
    level: ProgramLevel.intermedio,
    subtitle: 'Abs · Core funcional',
    weeks: 6,
    daysPerWeek: 4,
    exerciseCount: 8,
    tags: ['Core', 'Abdominales'],
    emoji: '🛡️',
    equipment: 'Sin material',
    colorIndex: 4,
    description: 'Construye un core fuerte y estético. Trabaja recto, oblicuos y transverso.',
    exercises: [
      ProgramExercise(order: 1, name: 'Plancha frontal lastrada', sets: 4, durationSeconds: 60, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Disco sobre espalda baja'),
      ProgramExercise(order: 2, name: 'Plancha lateral con peso', sets: 3, durationSeconds: 30, weightKg: 5, restSeconds: 45, measurementType: MeasurementType.weight, notes: '30s por lado'),
      ProgramExercise(order: 3, name: 'Cable crunch arrodillado', sets: 4, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Tirar codos a rodillas'),
      ProgramExercise(order: 4, name: 'Elevación piernas colgado', sets: 4, reps: 12, restSeconds: 60, measurementType: MeasurementType.reps),
      ProgramExercise(order: 5, name: 'Russian twist con disco', sets: 3, reps: 20, weightKg: 10, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Toca al lado izq y der'),
      ProgramExercise(order: 6, name: 'Hollow rocks', sets: 3, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps),
      ProgramExercise(order: 7, name: 'Pallof press en polea', sets: 3, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, notes: '12 por lado, antirrotación'),
      ProgramExercise(order: 8, name: 'Dragon flag', sets: 3, reps: 6, restSeconds: 60, measurementType: MeasurementType.reps, notes: 'Avanzado, alternativa: tuck'),
    ],
  ),
  ProgramModel(
    id: 'prog_531',
    title: '5/3/1 fuerza',
    category: ProgramCategory.programas,
    level: ProgramLevel.avanzado,
    subtitle: 'Fuerza máxima · Wendler',
    weeks: 4,
    daysPerWeek: 4,
    exerciseCount: 8,
    tags: ['Fuerza'],
    emoji: '🏆',
    equipment: 'Gym',
    colorIndex: 0,
    description: 'Programa Wendler 5/3/1: progresión lineal ondulada en los 4 grandes movimientos.',
    exercises: [
      ProgramExercise(order: 1, name: 'Press banca · 5/3/1', sets: 3, reps: 5, weightKg: 70, restSeconds: 180, measurementType: MeasurementType.weight, notes: 'S1: 5/5/5+ · S2: 3/3/3+ · S3: 5/3/1+'),
      ProgramExercise(order: 2, name: 'Accesorios push (BBB)', sets: 5, reps: 10, weightKg: 40, restSeconds: 90, measurementType: MeasurementType.weight, notes: '5×10 al 50%'),
      ProgramExercise(order: 3, name: 'Sentadilla · 5/3/1', sets: 3, reps: 5, weightKg: 90, restSeconds: 180, measurementType: MeasurementType.weight, notes: 'Mismo patrón'),
      ProgramExercise(order: 4, name: 'Accesorios legs (BBB)', sets: 5, reps: 10, weightKg: 50, restSeconds: 90, measurementType: MeasurementType.weight),
      ProgramExercise(order: 5, name: 'Press militar · 5/3/1', sets: 3, reps: 5, weightKg: 40, restSeconds: 180, measurementType: MeasurementType.weight, notes: 'De pie'),
      ProgramExercise(order: 6, name: 'Accesorios pull (BBB)', sets: 5, reps: 10, restSeconds: 90, measurementType: MeasurementType.reps, notes: 'Dominadas o remo'),
      ProgramExercise(order: 7, name: 'Peso muerto · 5/3/1', sets: 3, reps: 5, weightKg: 110, restSeconds: 180, measurementType: MeasurementType.weight),
      ProgramExercise(order: 8, name: 'Accesorios espalda (BBB)', sets: 5, reps: 10, weightKg: 50, restSeconds: 90, measurementType: MeasurementType.weight),
    ],
  ),
  ProgramModel(
    id: 'prog_movilidad_diaria',
    title: 'Movilidad diaria 10 min',
    category: ProgramCategory.programas,
    level: ProgramLevel.todos,
    subtitle: 'Mantenimiento · Movilidad',
    weeks: 4,
    daysPerWeek: 7,
    exerciseCount: 7,
    tags: ['Movilidad', 'Estiramientos'],
    emoji: '🧘',
    equipment: 'Sin material',
    colorIndex: 2,
    description: 'Rutina diaria corta para mantener movilidad articular y prevenir lesiones.',
    exercises: [
      ProgramExercise(order: 1, name: 'Cat-cow', sets: 1, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps),
      ProgramExercise(order: 2, name: 'Círculos de cadera', sets: 1, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps),
      ProgramExercise(order: 3, name: 'Sentadilla profunda', sets: 1, durationSeconds: 60, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Mantener 1 min'),
      ProgramExercise(order: 4, name: 'World\'s greatest stretch', sets: 1, reps: 8, restSeconds: 0, measurementType: MeasurementType.reps, notes: '4 por lado'),
      ProgramExercise(order: 5, name: 'Dislocaciones con palo', sets: 1, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps),
      ProgramExercise(order: 6, name: 'Dead hang', sets: 1, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Si tienes barra'),
      ProgramExercise(order: 7, name: 'Respiración diafragmática', sets: 1, durationSeconds: 60, restSeconds: 0, measurementType: MeasurementType.time),
    ],
  ),
  ProgramModel(
    id: 'prog_hiit_4semanas',
    title: 'Alta intensidad 4 semanas',
    category: ProgramCategory.programas,
    level: ProgramLevel.intermedio,
    subtitle: 'Quema grasa y gana resistencia',
    weeks: 4,
    daysPerWeek: 4,
    tags: ['HIIT'],
    emoji: '⚡',
    colorIndex: 4,
    exercises: [
      ProgramExercise(order: 1, name: 'Burpees', sets: 4, durationSeconds: 40, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/11601301-Burpee_Cardio_720.gif'),
      ProgramExercise(order: 2, name: 'Sentadilla con salto', sets: 4, durationSeconds: 40, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/04/15521301-Dumbbell-Jumping-Squat_Plyometric_720.gif'),
      ProgramExercise(order: 3, name: 'Mountain climbers', sets: 4, durationSeconds: 40, restSeconds: 45, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/06301301-Mountain-Climber_Cardio_720.gif'),
      ProgramExercise(order: 4, name: 'Flexiones', sets: 4, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/06621301-Push-up-m_Chest-FIX_720.gif'),
      ProgramExercise(order: 5, name: 'Plancha con salto', sets: 4, durationSeconds: 40, restSeconds: 45, measurementType: MeasurementType.time),
      ProgramExercise(order: 6, name: 'Sprint en sitio', sets: 4, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Máxima velocidad'),
    ],
  ),

  // ── Calentamientos ──
  ProgramModel(
    id: 'calent_superior',
    title: 'Calentamiento tren superior',
    category: ProgramCategory.calentamientos,
    level: ProgramLevel.todos,
    subtitle: 'Hombro / pecho / espalda',
    durationMin: 8,
    tags: ['Movilidad'],
    emoji: '🔥',
    colorIndex: 3,
    exercises: [
      ProgramExercise(order: 1, name: 'Circunducción de hombros', sets: 2, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps, notes: '10 adelante + 10 atrás'),
      ProgramExercise(order: 2, name: 'Rotación externa con banda', sets: 2, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps),
      ProgramExercise(order: 3, name: 'Dislocaciones con pica', sets: 2, reps: 10, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Agarre amplio progresivo'),
      ProgramExercise(order: 4, name: 'Retracción escapular', sets: 2, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Juntar escápulas 2 seg'),
      ProgramExercise(order: 5, name: 'Rotación torácica', sets: 2, reps: 8, restSeconds: 45, measurementType: MeasurementType.reps, notes: '8 por lado en cuadrupedia'),
      ProgramExercise(order: 6, name: 'Flexiones en pared', sets: 2, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Activación pectoral'),
    ],
  ),
  ProgramModel(
    id: 'calent_inferior',
    title: 'Calentamiento tren inferior',
    category: ProgramCategory.calentamientos,
    level: ProgramLevel.todos,
    subtitle: 'Cadera / rodilla / tobillo',
    durationMin: 10,
    tags: ['Movilidad'],
    emoji: '🔥',
    colorIndex: 4,
    exercises: [
      ProgramExercise(order: 1, name: 'Sentadilla profunda', sets: 2, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Sin peso, mantener talones'),
      ProgramExercise(order: 2, name: 'Zancada con rotación', sets: 2, reps: 8, restSeconds: 45, measurementType: MeasurementType.reps, notes: '8 por lado, girar torso'),
      ProgramExercise(order: 3, name: 'Círculos de cadera', sets: 2, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps, notes: '10 por sentido'),
      ProgramExercise(order: 4, name: 'Activación de glúteo', sets: 2, reps: 15, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Puente de glúteo'),
      ProgramExercise(order: 5, name: 'Movilidad de tobillo', sets: 2, reps: 10, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Rodilla al frente sobre pared'),
      ProgramExercise(order: 6, name: 'Balanceo de pierna', sets: 2, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps, notes: '10 por pierna, frontal y lateral'),
    ],
  ),
  ProgramModel(
    id: 'calent_prerunning',
    title: 'Activación pre-running',
    category: ProgramCategory.calentamientos,
    level: ProgramLevel.todos,
    subtitle: 'Tobillo / cadera / core',
    durationMin: 6,
    tags: ['Running', 'Movilidad'],
    emoji: '🔥',
    colorIndex: 5,
    exercises: [
      ProgramExercise(order: 1, name: 'Skipping', sets: 2, durationSeconds: 20, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Rodillas altas, brazos activos'),
      ProgramExercise(order: 2, name: 'Talones al glúteo', sets: 2, durationSeconds: 20, restSeconds: 45, measurementType: MeasurementType.time),
      ProgramExercise(order: 3, name: 'Activación glúteo', sets: 2, reps: 12, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Clamshell o puente'),
      ProgramExercise(order: 4, name: 'Movilidad tobillo', sets: 2, reps: 10, restSeconds: 45, measurementType: MeasurementType.reps),
      ProgramExercise(order: 5, name: 'Zancada dinámica', sets: 2, reps: 8, restSeconds: 45, measurementType: MeasurementType.reps, notes: '8 por pierna'),
    ],
  ),

  // ── Movilidad / Estiramientos ──
  ProgramModel(
    id: 'mov_hombro',
    title: 'Movilidad de hombro',
    category: ProgramCategory.estiramientos,
    level: ProgramLevel.todos,
    subtitle: 'Recuperación',
    durationMin: 7,
    tags: ['Movilidad'],
    emoji: '🧘',
    colorIndex: 2,
    exercises: [
      ProgramExercise(order: 1, name: 'Estiramiento pectoral en pared', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: '30s por lado'),
      ProgramExercise(order: 2, name: 'Rotación interna/externa', sets: 2, reps: 10, restSeconds: 45, measurementType: MeasurementType.reps, notes: 'Con banda elástica'),
      ProgramExercise(order: 3, name: 'Sleeper stretch', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Tumbado de lado'),
      ProgramExercise(order: 4, name: 'Dislocaciones con banda', sets: 2, reps: 10, restSeconds: 45, measurementType: MeasurementType.reps),
      ProgramExercise(order: 5, name: 'Cruz en pared', sets: 2, durationSeconds: 25, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Brazo extendido contra pared'),
    ],
  ),
  ProgramModel(
    id: 'mov_cadera',
    title: 'Movilidad de cadera',
    category: ProgramCategory.estiramientos,
    level: ProgramLevel.todos,
    subtitle: 'Recuperación',
    durationMin: 10,
    tags: ['Movilidad'],
    emoji: '🧘',
    colorIndex: 5,
    exercises: [
      ProgramExercise(order: 1, name: '90/90', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: '30s por lado'),
      ProgramExercise(order: 2, name: 'Mariposa sentado', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Presionar rodillas hacia el suelo'),
      ProgramExercise(order: 3, name: 'Zancada profunda', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: '30s por lado, empujar cadera'),
      ProgramExercise(order: 4, name: 'Estiramiento piriforme', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Tobillo sobre rodilla opuesta'),
      ProgramExercise(order: 5, name: 'Sentadilla profunda isométrica', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Codos empujan rodillas afuera'),
    ],
  ),
  ProgramModel(
    id: 'est_post_pierna',
    title: 'Estiramientos post pierna',
    category: ProgramCategory.estiramientos,
    level: ProgramLevel.todos,
    subtitle: 'Recuperación',
    durationMin: 8,
    tags: ['Estiramientos'],
    emoji: '🧘',
    colorIndex: 0,
    exercises: [
      ProgramExercise(order: 1, name: 'Estiramiento isquiotibiales', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'De pie o sentado, 30s por pierna'),
      ProgramExercise(order: 2, name: 'Estiramiento cuádriceps', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'De pie, talón al glúteo'),
      ProgramExercise(order: 3, name: 'Estiramiento gemelos', sets: 2, durationSeconds: 25, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Contra pared, pierna atrás'),
      ProgramExercise(order: 4, name: 'Estiramiento aductores', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Zancada lateral'),
      ProgramExercise(order: 5, name: 'Estiramiento glúteo', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Pierna cruzada sentado'),
    ],
  ),
  ProgramModel(
    id: 'est_post_torso',
    title: 'Estiramientos post torso',
    category: ProgramCategory.estiramientos,
    level: ProgramLevel.todos,
    subtitle: 'Recuperación',
    durationMin: 7,
    tags: ['Estiramientos'],
    emoji: '🧘',
    colorIndex: 1,
    exercises: [
      ProgramExercise(order: 1, name: 'Estiramiento pectoral', sets: 2, durationSeconds: 25, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Brazo en marco de puerta'),
      ProgramExercise(order: 2, name: 'Estiramiento dorsal', sets: 2, durationSeconds: 25, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Colgarse de barra o estirar en pared'),
      ProgramExercise(order: 3, name: 'Estiramiento hombro', sets: 2, durationSeconds: 25, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Brazo cruzado al pecho'),
      ProgramExercise(order: 4, name: 'Estiramiento tríceps', sets: 2, durationSeconds: 20, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Mano detrás de cabeza, codo arriba'),
      ProgramExercise(order: 5, name: 'Estiramiento trapecio', sets: 2, durationSeconds: 20, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Inclinar cabeza lateral'),
    ],
  ),
  ProgramModel(
    id: 'calent_fullbody',
    title: 'Calentamiento full body',
    category: ProgramCategory.calentamientos,
    level: ProgramLevel.todos,
    subtitle: 'Activación general',
    durationMin: 10,
    tags: ['Movilidad'],
    emoji: '🔥',
    colorIndex: 0,
    exercises: [
      ProgramExercise(order: 1, name: 'Saltos de tijera', sets: 1, durationSeconds: 60, restSeconds: 0, measurementType: MeasurementType.time, gifUrl: 'https://fitcron.com/wp-content/uploads/2021/03/30941301-Jumping-Jack-male_Cardio_720.gif'),
      ProgramExercise(order: 2, name: 'Cat-cow', sets: 2, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps),
      ProgramExercise(order: 3, name: 'World\'s greatest stretch', sets: 2, reps: 6, restSeconds: 0, measurementType: MeasurementType.reps, notes: '6 por lado'),
      ProgramExercise(order: 4, name: 'Sentadilla con peso corporal', sets: 2, reps: 15, restSeconds: 0, measurementType: MeasurementType.reps),
      ProgramExercise(order: 5, name: 'Flexiones progresivas', sets: 2, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps),
      ProgramExercise(order: 6, name: 'Círculos de brazos', sets: 2, reps: 15, restSeconds: 0, measurementType: MeasurementType.reps, notes: '15 adelante + 15 atrás'),
      ProgramExercise(order: 7, name: 'Rotación torácica', sets: 2, reps: 8, restSeconds: 0, measurementType: MeasurementType.reps, notes: '8 por lado'),
    ],
  ),
  ProgramModel(
    id: 'calent_brazos',
    title: 'Calentamiento brazos',
    category: ProgramCategory.calentamientos,
    level: ProgramLevel.todos,
    subtitle: 'Codo / muñeca / hombro',
    durationMin: 5,
    tags: ['Movilidad', 'Brazos'],
    emoji: '🔥',
    colorIndex: 1,
    exercises: [
      ProgramExercise(order: 1, name: 'Círculos de muñeca', sets: 2, reps: 15, restSeconds: 0, measurementType: MeasurementType.reps, notes: '15 por sentido'),
      ProgramExercise(order: 2, name: 'Estiramiento de antebrazo', sets: 2, durationSeconds: 20, restSeconds: 0, measurementType: MeasurementType.time, notes: '20s por brazo'),
      ProgramExercise(order: 3, name: 'Curl ligero con mancuernas', sets: 2, reps: 15, weightKg: 4, restSeconds: 30, measurementType: MeasurementType.weight, notes: 'Activación bíceps'),
      ProgramExercise(order: 4, name: 'Extensión ligera tríceps', sets: 2, reps: 15, weightKg: 4, restSeconds: 30, measurementType: MeasurementType.weight),
      ProgramExercise(order: 5, name: 'Círculos de hombro', sets: 2, reps: 12, restSeconds: 0, measurementType: MeasurementType.reps),
    ],
  ),
  ProgramModel(
    id: 'calent_push',
    title: 'Calentamiento día Push',
    category: ProgramCategory.calentamientos,
    level: ProgramLevel.todos,
    subtitle: 'Pecho / hombro / tríceps',
    durationMin: 8,
    tags: ['Movilidad', 'Push'],
    emoji: '🔥',
    colorIndex: 0,
    exercises: [
      ProgramExercise(order: 1, name: 'Bike o caminar 5 min', sets: 1, durationSeconds: 300, restSeconds: 0, measurementType: MeasurementType.time),
      ProgramExercise(order: 2, name: 'Dislocaciones con banda', sets: 2, reps: 12, restSeconds: 0, measurementType: MeasurementType.reps),
      ProgramExercise(order: 3, name: 'Rotación externa con banda', sets: 2, reps: 15, restSeconds: 30, measurementType: MeasurementType.reps),
      ProgramExercise(order: 4, name: 'Flexiones progresivas', sets: 2, reps: 10, restSeconds: 30, measurementType: MeasurementType.reps),
      ProgramExercise(order: 5, name: 'Press banca solo barra', sets: 2, reps: 12, weightKg: 20, restSeconds: 45, measurementType: MeasurementType.weight, notes: 'Series de calentamiento'),
    ],
  ),
  ProgramModel(
    id: 'calent_pull',
    title: 'Calentamiento día Pull',
    category: ProgramCategory.calentamientos,
    level: ProgramLevel.todos,
    subtitle: 'Espalda / bíceps / posterior',
    durationMin: 8,
    tags: ['Movilidad', 'Pull'],
    emoji: '🔥',
    colorIndex: 2,
    exercises: [
      ProgramExercise(order: 1, name: 'Remo en bicicleta o cinta', sets: 1, durationSeconds: 300, restSeconds: 0, measurementType: MeasurementType.time),
      ProgramExercise(order: 2, name: 'Dead hang', sets: 2, durationSeconds: 20, restSeconds: 30, measurementType: MeasurementType.time),
      ProgramExercise(order: 3, name: 'Band pull-aparts', sets: 3, reps: 15, restSeconds: 30, measurementType: MeasurementType.reps),
      ProgramExercise(order: 4, name: 'Activación escapular en barra', sets: 2, reps: 8, restSeconds: 30, measurementType: MeasurementType.reps, notes: 'Escapular pull-ups'),
      ProgramExercise(order: 5, name: 'Face pull ligero', sets: 2, reps: 15, restSeconds: 30, measurementType: MeasurementType.reps),
    ],
  ),
  ProgramModel(
    id: 'calent_cuello',
    title: 'Movilidad de cuello',
    category: ProgramCategory.calentamientos,
    level: ProgramLevel.todos,
    subtitle: 'Cervical · Activación',
    durationMin: 5,
    tags: ['Movilidad'],
    emoji: '🔥',
    colorIndex: 3,
    exercises: [
      ProgramExercise(order: 1, name: 'Inclinación lateral', sets: 2, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps, notes: '10 por lado'),
      ProgramExercise(order: 2, name: 'Rotaciones lentas de cuello', sets: 2, reps: 8, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Rango cómodo'),
      ProgramExercise(order: 3, name: 'Chin tucks', sets: 2, reps: 12, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Doble mentón'),
      ProgramExercise(order: 4, name: 'Estiramiento trapecio', sets: 2, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time, notes: '30s por lado'),
      ProgramExercise(order: 5, name: 'Estiramiento ECM', sets: 2, durationSeconds: 25, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Mirar techo y rotar'),
    ],
  ),

  // ── Estiramientos adicionales ──
  ProgramModel(
    id: 'est_post_brazos',
    title: 'Estiramientos post brazos',
    category: ProgramCategory.estiramientos,
    level: ProgramLevel.todos,
    subtitle: 'Recuperación brazos',
    durationMin: 6,
    tags: ['Estiramientos', 'Brazos'],
    emoji: '🧘',
    colorIndex: 4,
    exercises: [
      ProgramExercise(order: 1, name: 'Estiramiento bíceps en pared', sets: 2, durationSeconds: 25, restSeconds: 0, measurementType: MeasurementType.time, notes: '25s por brazo'),
      ProgramExercise(order: 2, name: 'Estiramiento tríceps sobre cabeza', sets: 2, durationSeconds: 25, restSeconds: 0, measurementType: MeasurementType.time, notes: '25s por brazo'),
      ProgramExercise(order: 3, name: 'Estiramiento antebrazo', sets: 2, durationSeconds: 25, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Palma arriba y abajo'),
      ProgramExercise(order: 4, name: 'Cruz en pared', sets: 2, durationSeconds: 25, restSeconds: 0, measurementType: MeasurementType.time),
      ProgramExercise(order: 5, name: 'Estiramiento de muñeca', sets: 2, durationSeconds: 20, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Suave, ambas direcciones'),
    ],
  ),
  ProgramModel(
    id: 'est_full_body',
    title: 'Estiramiento full body',
    category: ProgramCategory.estiramientos,
    level: ProgramLevel.todos,
    subtitle: 'Vuelta a la calma',
    durationMin: 12,
    tags: ['Estiramientos', 'Movilidad'],
    emoji: '🧘',
    colorIndex: 2,
    exercises: [
      ProgramExercise(order: 1, name: 'Child pose', sets: 1, durationSeconds: 45, restSeconds: 0, measurementType: MeasurementType.time),
      ProgramExercise(order: 2, name: 'Perro boca abajo', sets: 1, durationSeconds: 45, restSeconds: 0, measurementType: MeasurementType.time),
      ProgramExercise(order: 3, name: 'Cobra', sets: 1, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time),
      ProgramExercise(order: 4, name: 'Estiramiento isquios', sets: 1, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time, notes: '30s por pierna'),
      ProgramExercise(order: 5, name: 'Estiramiento cuádriceps de pie', sets: 1, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time, notes: '30s por pierna'),
      ProgramExercise(order: 6, name: 'Mariposa sentado', sets: 1, durationSeconds: 45, restSeconds: 0, measurementType: MeasurementType.time),
      ProgramExercise(order: 7, name: 'Torsión espinal tumbado', sets: 1, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time, notes: '30s por lado'),
      ProgramExercise(order: 8, name: 'Pose del niño feliz', sets: 1, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time),
      ProgramExercise(order: 9, name: 'Savasana', sets: 1, durationSeconds: 60, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Respiración profunda'),
    ],
  ),
  ProgramModel(
    id: 'est_movilidad_tobillo',
    title: 'Movilidad de tobillo',
    category: ProgramCategory.estiramientos,
    level: ProgramLevel.todos,
    subtitle: 'Prevención · Tobillo',
    durationMin: 6,
    tags: ['Movilidad'],
    emoji: '🧘',
    colorIndex: 5,
    exercises: [
      ProgramExercise(order: 1, name: 'Círculos de tobillo', sets: 2, reps: 15, restSeconds: 0, measurementType: MeasurementType.reps, notes: '15 por sentido y pie'),
      ProgramExercise(order: 2, name: 'Dorsiflexión contra pared', sets: 2, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps, notes: '10 por pie, rodilla al frente'),
      ProgramExercise(order: 3, name: 'Punta-talón', sets: 2, reps: 15, restSeconds: 0, measurementType: MeasurementType.reps),
      ProgramExercise(order: 4, name: 'Sentadilla con talones elevados', sets: 2, reps: 10, restSeconds: 30, measurementType: MeasurementType.reps, notes: 'Calza disco bajo talones'),
      ProgramExercise(order: 5, name: 'Estiramiento gemelos en pared', sets: 2, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time, notes: '30s por pierna'),
      ProgramExercise(order: 6, name: 'Estiramiento sóleo (rodilla flexionada)', sets: 2, durationSeconds: 25, restSeconds: 0, measurementType: MeasurementType.time, notes: '25s por pierna'),
    ],
  ),
  ProgramModel(
    id: 'est_yoga_recuperacion',
    title: 'Yoga recuperación',
    category: ProgramCategory.estiramientos,
    level: ProgramLevel.todos,
    subtitle: 'Día de descanso',
    durationMin: 20,
    tags: ['Estiramientos', 'Movilidad'],
    emoji: '🧘',
    colorIndex: 1,
    exercises: [
      ProgramExercise(order: 1, name: 'Saludo al sol A', sets: 3, reps: 1, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Flujo respiración'),
      ProgramExercise(order: 2, name: 'Guerrero II', sets: 1, durationSeconds: 45, restSeconds: 0, measurementType: MeasurementType.time, notes: '45s por lado'),
      ProgramExercise(order: 3, name: 'Triángulo', sets: 1, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time, notes: '30s por lado'),
      ProgramExercise(order: 4, name: 'Pinza de pie', sets: 1, durationSeconds: 60, restSeconds: 0, measurementType: MeasurementType.time),
      ProgramExercise(order: 5, name: 'Paloma', sets: 1, durationSeconds: 60, restSeconds: 0, measurementType: MeasurementType.time, notes: '60s por lado'),
      ProgramExercise(order: 6, name: 'Puente bajo', sets: 1, durationSeconds: 45, restSeconds: 0, measurementType: MeasurementType.time),
      ProgramExercise(order: 7, name: 'Piernas en pared', sets: 1, durationSeconds: 120, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Recuperación'),
      ProgramExercise(order: 8, name: 'Savasana', sets: 1, durationSeconds: 180, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Relajación final'),
    ],
  ),
  ProgramModel(
    id: 'est_espalda_cadera',
    title: 'Espalda y cadera',
    category: ProgramCategory.estiramientos,
    level: ProgramLevel.todos,
    subtitle: 'Movilidad general',
    durationMin: 10,
    tags: ['Movilidad', 'Estiramientos'],
    emoji: '🧘',
    colorIndex: 3,
    exercises: [
      ProgramExercise(order: 1, name: 'Cat-cow', sets: 2, reps: 10, restSeconds: 0, measurementType: MeasurementType.reps, notes: 'Cuadrupedia, alternar flexión/extensión'),
      ProgramExercise(order: 2, name: 'Child pose', sets: 2, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time, notes: 'Brazos extendidos, frente al suelo'),
      ProgramExercise(order: 3, name: 'Rotación torácica', sets: 2, reps: 8, restSeconds: 45, measurementType: MeasurementType.reps, notes: '8 por lado en cuadrupedia'),
      ProgramExercise(order: 4, name: 'Estiramiento piriforme', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Tumbado, tobillo sobre rodilla'),
      ProgramExercise(order: 5, name: 'Perro boca abajo', sets: 2, durationSeconds: 30, restSeconds: 45, measurementType: MeasurementType.time, notes: 'Talones al suelo, extender columna'),
      ProgramExercise(order: 6, name: 'Torsión espinal tumbado', sets: 2, durationSeconds: 30, restSeconds: 0, measurementType: MeasurementType.time, notes: '30s por lado, hombros pegados al suelo'),
    ],
  ),
];
