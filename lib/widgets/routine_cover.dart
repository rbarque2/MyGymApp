import '../models/routine_model.dart';

/// Portadas de respaldo (Unsplash, mismas claves bakeadas que los programas)
/// para rutinas creadas por el usuario sin foto propia.
const _fallbackCovers = [
  'https://images.unsplash.com/photo-1558611848-73f7eb4001a1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5MjkzNDR8MHwxfHNlYXJjaHwxfHxiYXJiZWxsJTIwc3F1YXQlMjBneW18ZW58MHwwfHx8MTc3NjYwNjI5MHww&ixlib=rb-4.1.0&q=80&w=1080',
  'https://images.unsplash.com/photo-1677165733273-dcc3724c00e8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5MjkzNDR8MHwxfHNlYXJjaHwxfHxwdWxsJTIwdXAlMjBiYXIlMjBiYWNrJTIwd29ya291dHxlbnwwfDB8fHwxNzc2NjA2MjkxfDA&ixlib=rb-4.1.0&q=80&w=1080',
  'https://images.unsplash.com/photo-1717821681365-36b0da044a75?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5MjkzNDR8MHwxfHNlYXJjaHwxfHxwbGFuayUyMGFicyUyMHdvcmtvdXR8ZW58MHwwfHx8MTc3NjYwNjI5Mnww&ixlib=rb-4.1.0&q=80&w=1080',
  'https://images.unsplash.com/photo-1585342565162-3704ff9b221d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5MjkzNDR8MHwxfHNlYXJjaHwxfHxiaWNlcHMlMjBjdXJsJTIwZHVtYmJlbGx8ZW58MHwwfHx8MTc3NjYwNjI5M3ww&ixlib=rb-4.1.0&q=80&w=1080',
  'https://images.unsplash.com/photo-1598268030450-7a476f602bf6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5MjkzNDR8MHwxfHNlYXJjaHwxfHx0cmljZXBzJTIwZ3ltfGVufDB8MHx8fDE3NzY2MDcyMDN8MA&ixlib=rb-4.1.0&q=80&w=1080',
  'https://images.unsplash.com/photo-1548933122-5fedf3661c57?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5MjkzNDR8MHwxfHNlYXJjaHwxfHxzaG91bGRlciUyMHByZXNzJTIwZ3ltfGVufDB8MHx8fDE3NzY2MDYyOTV8MA&ixlib=rb-4.1.0&q=80&w=1080',
  'https://images.unsplash.com/photo-1767404890803-228d5390fcd4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5MjkzNDR8MHwxfHNlYXJjaHwxfHxnbHV0ZSUyMHdvcmtvdXR8ZW58MHwwfHx8MTc3NjYwNjM1M3ww&ixlib=rb-4.1.0&q=80&w=1080',
  'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w5MjkzNDR8MHwxfHNlYXJjaHwxfHxhYnMlMjB3b3Jrb3V0fGVufDB8MHx8fDE3NzY2MDYzNTR8MA&ixlib=rb-4.1.0&q=80&w=1080',
];

/// URL de portada para una rutina, por orden de preferencia: su foto propia,
/// la foto del primer ejercicio que tenga una, o una del set de respaldo
/// elegida de forma estable por el nombre (hash determinista, independiente
/// de la plataforma).
String routineCoverUrl(RoutineModel routine) {
  final photo = routine.photoUrl;
  if (photo != null && photo.isNotEmpty) return photo;
  for (final exercise in routine.exercises) {
    final exercisePhoto = exercise.photoUrl;
    if (exercisePhoto != null && exercisePhoto.isNotEmpty) {
      return exercisePhoto;
    }
  }
  final hash = routine.name.codeUnits.fold<int>(0, (acc, c) => acc * 31 + c);
  return _fallbackCovers[hash.abs() % _fallbackCovers.length];
}
