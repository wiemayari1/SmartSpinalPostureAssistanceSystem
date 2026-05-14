import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  int get langIndex {
    switch (locale.languageCode) {
      case 'ar':
        return 1;
      case 'en':
        return 2;
      default:
        return 0;
    }
  }

  bool get isRtl => locale.languageCode == 'ar';

  String _t(String fr, String ar, String en) {
    switch (locale.languageCode) {
      case 'ar':
        return ar;
      case 'en':
        return en;
      default:
        return fr;
    }
  }

  List<String> _tList(List<String> fr, List<String> ar, List<String> en) {
    switch (locale.languageCode) {
      case 'ar':
        return ar;
      case 'en':
        return en;
      default:
        return fr;
    }
  }

  // ============================================================
  // NAVIGATION & GÉNÉRAL
  // ============================================================
  String get appTitle => 'SpineGuard';
  String get dashboard => _t('Tableau de bord', 'لوحة القيادة', 'Dashboard');
  String get chatbot => _t('Assistant', 'المساعد', 'Assistant');
  String get exercises => _t('Exercices', 'التمارين', 'Exercises');
  String get history => _t('Historique', 'السجل', 'History');
  String get settings => _t('Paramètres', 'الإعدادات', 'Settings');
  String get exercisesCount => _t('exercices', 'تمارين', 'exercises');

  // ============================================================
  // DASHBOARD
  // ============================================================
  String get connected => _t('Connecté', 'متصل', 'Connected');
  String get disconnected => _t('Déconnecté', 'غير متصل', 'Disconnected');
  String get pitch => _t('Inclinaison', 'الميل', 'Pitch');
  String get roll => _t('Rotation', 'الدوران', 'Roll');
  String get deviation => _t('Déviation', 'الانحراف', 'Deviation');
  String get sessionDuration =>
      _t('Durée session', 'مدة الجلسة', 'Session duration');
  String get totalAlerts => _t('Alertes', 'التنبيهات', 'Alerts');
  String get badPostureTime =>
      _t('Mauvaise posture', 'وضعية سيئة', 'Bad posture');
  String get goodPosture => _t('Bonne posture', 'وضعية جيدة', 'Good posture');
  String get recalibrate => _t('Recalibrer', 'إعادة المعايرة', 'Recalibrate');
  String get calibrating =>
      _t('Calibration en cours...', 'جارٍ المعايرة...', 'Calibrating...');
  String get calibrationDone =>
      _t('Calibration terminée !', 'تمت المعايرة !', 'Calibration done!');
  String get calibrationFail =>
      _t('Échec de la calibration', 'فشلت المعايرة', 'Calibration failed');
  String get waitingEsp32 =>
      _t('En attente ESP32...', 'في انتظار ESP32...', 'Waiting for ESP32...');
  String get esp32NotConnected => _t(
        'ESP32 non connecté\nVérifiez l\'IP dans Paramètres.',
        'ESP32 غير متصل\nتحقق من عنوان IP في الإعدادات.',
        'ESP32 not connected\nCheck IP in Settings.',
      );

  // États posturaux
  String get stateGood => _t('Bonne posture', 'وضعية جيدة', 'Good posture');
  String get stateWarning => _t('Avertissement', 'تحذير', 'Warning');
  String get stateBad => _t('Mauvaise posture', 'وضعية سيئة', 'Bad posture');
  String get stateCritical =>
      _t('Posture critique', 'وضعية خطيرة', 'Critical posture');
  String get stateUnknown => _t('Inconnu', 'غير معروف', 'Unknown');

  // ============================================================
  // HISTORIQUE
  // ============================================================
  String get pitchChart => _t('Inclinaison (°)', 'الميل (°)', 'Pitch (°)');
  String get rollChart => _t('Rotation (°)', 'الدوران (°)', 'Roll (°)');
  String get noDataYet => _t(
        'Aucune donnée encore.\nLe graphique se remplit avec le temps.',
        'لا توجد بيانات بعد.\nسيمتلئ الرسم البياني بمرور الوقت.',
        'No data yet.\nThe chart fills up over time.',
      );
  String get sessionSummary =>
      _t('Résumé session', 'ملخص الجلسة', 'Session summary');
  String get totalDuration =>
      _t('Durée totale', 'المدة الإجمالية', 'Total duration');

  // ============================================================
  // PARAMÈTRES
  // ============================================================
  String get esp32Ip =>
      _t('Adresse IP ESP32', 'عنوان IP لـ ESP32', 'ESP32 IP address');
  String get ipHint =>
      _t('ex: 192.168.1.42', 'مثال: 192.168.1.42', 'e.g. 192.168.1.42');
  String get ipSaved => _t('IP enregistrée', 'تم حفظ IP', 'IP saved');
  String get testConnection => _t('Tester la connexion', 'اختبار الاتصال', 'Test connection');
  String get testInProgress => _t('Test en cours...', 'جارٍ الاختبار...', 'Testing...');
  String get testSuccess => _t('Connexion réussie', 'تم الاتصال بنجاح', 'Connection successful');
  String get language => _t('Langue', 'اللغة', 'Language');
  String get voice => _t('Voix activée', 'الصوت مفعّل', 'Voice on');
  String get voiceOff => _t('Voix désactivée', 'الصوت معطّل', 'Voice off');
  String get voiceSubtitle => _t(
        'Annonces vocales automatiques',
        'إعلانات صوتية تلقائية',
        'Automatic voice announcements',
      );
  String get silentMode => _t('Mode silencieux (buzzer)',
      'الوضع الصامت (البازر)', 'Silent mode (buzzer)');
  String get silentSubtitle => _t(
        'Désactiver le buzzer de l\'ESP32',
        'تعطيل بازر ESP32',
        'Disable ESP32 buzzer',
      );
  String get resetSession =>
      _t('Réinitialiser la session', 'إعادة تعيين الجلسة', 'Reset session');
  String get resetBtn => _t('Réinitialiser', 'إعادة تعيين', 'Reset');
  String get resetSuccess =>
      _t('Session réinitialisée', 'تمت إعادة التعيين', 'Session reset');
  String get resetError => _t('Erreur', 'خطأ', 'Error');
  String get about => _t('À propos', 'حول', 'About');
  String get aboutAuthors => _t(
        'Développée par Ayari Wiem et Sakroufi Aya dans le cadre d\'un projet académique.',
        'طُوِّر بواسطة عياري ويام وصقروفي آية في إطار مشروع أكاديمي.',
        'Developed by Ayari Wiem and Sakroufi Aya as part of an academic project.',
      );
  String get aboutDescription => _t(
        'SpineGuard est une application de surveillance de posture en temps réel. Elle se connecte via Wi-Fi à une ceinture intelligente équipée d\'un capteur ESP32 et d\'un accéléromètre MPU6050, portée au niveau du dos. Le capteur détecte en permanence l\'inclinaison et les angles de la colonne vertébrale, puis envoie les données à l\'application qui analyse la posture, déclenche des alertes en cas de mauvaise position et propose des exercices correctifs.',
        'SpineGuard تطبيق لمراقبة وضعية الجسم في الوقت الفعلي. يتصل عبر Wi-Fi بحزام ذكي مزوّد بمستشعر ESP32 ومقياس تسارع MPU6050 يُثبَّت على الظهر. يكشف المستشعر باستمرار ميلان العمود الفقري وزواياه، ويرسل البيانات إلى التطبيق الذي يحلل الوضعية ويطلق تنبيهات عند الجلوس بشكل خاطئ ويقترح تمارين تصحيحية.',
        'SpineGuard is a real-time posture monitoring app. It connects via Wi-Fi to a smart belt equipped with an ESP32 sensor and MPU6050 accelerometer worn on the back. The sensor continuously detects spinal inclination and angles, sending data to the app which analyses posture, triggers alerts for bad positions and suggests corrective exercises.',
      );
  String get aboutClass =>
      _t('Classe : 1ING03', 'الفصل: 1ING03', 'Class: 1ING03');
  String get aboutHardware => _t(
        'ESP32 + MPU6050 + LED RGB + Buzzer 5V',
        'ESP32 + MPU6050 + LED RGB + Buzzer 5V',
        'ESP32 + MPU6050 + RGB LED + Buzzer 5V',
      );
  String get aboutCloud => _t(
        'Cloud : n8n.io + Supabase PostgreSQL',
        'السحابة: n8n.io + Supabase',
        'Cloud: n8n.io + Supabase PostgreSQL',
      );

  // ── Thème ──
  String get appearance    => _t('Apparence', 'المظهر', 'Appearance');
  String get darkMode      => _t('Mode sombre', 'الوضع المظلم', 'Dark mode');
  String get lightMode     => _t('Mode clair', 'الوضع الفاتح', 'Light mode');
  String get themeSubtitle => _t(
        'Changer l\'apparence de l\'app',
        'تغيير مظهر التطبيق',
        'Change app appearance',
      );

  // ============================================================
  // CHATBOT
  // ============================================================
  String get spinebot => 'SpineBot';
  String get spinebotSub =>
      _t('Assistant intelligent', 'مساعد ذكي', 'Smart assistant');
  String get howCanIHelp => _t(
        'Comment puis-je vous aider ?',
        'كيف يمكنني مساعدتك؟',
        'How can I help you?',
      );
  String get typeMessage => _t(
        'Écrivez votre message...',
        'اكتب رسالتك...',
        'Type your message...',
      );
  String get myPosture => _t('Ma posture', 'وضعيتي', 'My posture');
  String get exercisesBtn => _t('Exercices', 'تمارين', 'Exercises');
  String get adviceBtn => _t('Conseils', 'نصائح', 'Advice');
  String get reportBtn => _t('Rapport', 'تقرير', 'Report');
  String get breakBtn => _t('Pause', 'استراحة', 'Break');
  String get calibrateBtn => _t('Calibration', 'معايرة', 'Calibrate');

  String get cmdPosture => _t('posture', 'وضعية', 'posture');
  String get cmdExercise => _t('exercice', 'تمرين', 'exercise');
  String get cmdAdvice => _t('conseil', 'نصيحة', 'advice');
  String get cmdReport => _t('rapport', 'تقرير', 'report');
  String get cmdBreak => _t('pause', 'استراحة', 'break');
  String get cmdCalibrate => _t('calibrer', 'معايرة', 'calibrate');

  // ============================================================
  // EXERCICES — Labels page détaillée
  // ============================================================
  String get catStretching => _t('Étirements', 'إطالات', 'Stretching');
  String get catBreathing => _t('Respiration', 'تنفس', 'Breathing');
  String get catCardio => _t('Cardio', 'كارديو', 'Cardio');
  String get catEye => _t('Repos oculaire', 'راحة العين', 'Eye rest');
  String get catStrength => _t('Renforcement', 'تقوية', 'Strength');

  String get exDuration => _t('Durée', 'المدة', 'Duration');
  String get exSteps => _t('Étapes', 'خطوات', 'Steps');
  String get exType => _t('Type', 'النوع', 'Type');
  String get exDescription => _t('Description', 'الوصف', 'Description');
  String get exHowTo => _t('Comment faire', 'كيفية الأداء', 'How to do it');
  String get exBenefits => _t('Bénéfices', 'الفوائد', 'Benefits');
  String get exStart => _t('Commencer', 'ابدأ', 'Start');
  String get exStop => _t('Arrêter', 'إيقاف', 'Stop');
  String get exRestart => _t('Recommencer', 'إعادة', 'Restart');
  String get exDone => _t('Terminé !', 'انتهى!', 'Done!');

  // Méthode (pas un getter) — corrige l'erreur de compilation
  String exCount(int count) =>
      _t('$count exercices', '$count تمارين', '$count exercises');

  // ============================================================
  // EXERCICE 1 : Rotation des épaules
  // ============================================================
  String get ex1Title =>
      _t('Rotation des épaules', 'تدوير الكتفين', 'Shoulder rolls');
  String get ex1Desc => _t(
        'Soulage les tensions dans les trapèzes et améliore la mobilité scapulaire.',
        'يخفف التوتر في عضلات الكتف ويحسن حركة مفصل الكتف.',
        'Relieves tension in the trapezius and improves shoulder mobility.',
      );
  List<String> get ex1Steps => _tList(
        [
          'Assis ou debout, dos droit',
          'Levez les épaules vers les oreilles',
          'Tournez vers l\'arrière en cercle',
          'Descendez et revenez au départ',
          'Répétez 10 fois, puis inversez'
        ],
        [
          'جالساً أو واقفاً، ظهرك مستقيم',
          'ارفع كتفيك نحو أذنيك',
          'دورهما للخلف في حركة دائرية',
          'انزل وعد إلى الوضع الأول',
          'كرر 10 مرات، ثم اعكس الاتجاه'
        ],
        [
          'Sit or stand with your back straight',
          'Lift your shoulders toward your ears',
          'Roll them backward in a circle',
          'Lower and return to start',
          'Repeat 10 times, then reverse'
        ],
      );
  List<String> get ex1Benefits => _tList(
        [
          'Réduit les tensions cervicales',
          'Améliore la circulation',
          'Prévient les douleurs'
        ],
        ['يقلل توتر الرقبة', 'يحسن الدورة الدموية', 'يمنع الألم'],
        ['Reduces neck tension', 'Improves circulation', 'Prevents pain'],
      );

  // ============================================================
  // EXERCICE 2 : Inclinaison du cou
  // ============================================================
  String get ex2Title => _t('Inclinaison du cou', 'إمالة الرقبة', 'Neck tilt');
  String get ex2Desc => _t(
        'Étire les muscles cervicaux et soulage les tensions du cou.',
        'يمدد عضلات الرقبة ويخفف التوتر.',
        'Stretches the cervical muscles and relieves neck tension.',
      );
  List<String> get ex2Steps => _tList(
        [
          'Assis bien droit, épaules relâchées',
          'Inclinez la tête vers la gauche',
          'Maintenez 10 secondes',
          'Revenez au centre',
          'Inclinez vers la droite 10 secondes'
        ],
        [
          'اجلس مستقيماً، كتفاك مرتخيان',
          'أمل رأسك نحو اليسار برفق',
          'ابق 10 ثوانٍ وأنت تتنفس',
          'عد إلى المركز',
          'أمل نحو اليمين 10 ثوانٍ'
        ],
        [
          'Sit upright, shoulders relaxed',
          'Gently tilt your head to the left',
          'Hold for 10 seconds while breathing',
          'Return to center',
          'Tilt to the right for 10 seconds'
        ],
      );
  List<String> get ex2Benefits => _tList(
        [
          'Étire les muscles cervicaux',
          'Réduit les maux de tête',
          'Améliore la posture'
        ],
        ['يمدد عضلات الرقبة', 'يقلل الصداع', 'يحسن الوضعية'],
        ['Stretches cervical muscles', 'Reduces headaches', 'Improves posture'],
      );

  // ============================================================
  // EXERCICE 3 : Chat-vache
  // ============================================================
  String get ex3Title => _t('Chat-vache', 'وضعية القطة والبقرة', 'Cat-cow');
  String get ex3Desc => _t(
        'Mobilise toute la colonne vertébrale et soulage les tensions lombaires.',
        'يحرك العمود الفقري بالكامل ويخفف توتر أسفل الظهر.',
        'Mobilizes the entire spine and relieves lower back tension.',
      );
  List<String> get ex3Steps => _tList(
        [
          'À 4 pattes, mains sous les épaules',
          'CHAT : expirez, arrondissez le dos',
          'Rentrez le menton vers la poitrine',
          'VACHE : inspirez, creusez le dos',
          'Levez tête et coccyx',
          'Alternez 10 fois lentement'
        ],
        [
          'على أربع، اليدان تحت الكتفين',
          'القطة: ازفر، قوس ظهرك للأعلى',
          'اسحب ذقنك نحو صدرك',
          'البقرة: شهق، اخفض بطنك',
          'ارفع رأسك والعصعص',
          'بادل بين الوضعين 10 مرات'
        ],
        [
          'On all fours, hands under shoulders',
          'CAT: exhale, round your back up',
          'Tuck chin toward chest',
          'COW: inhale, drop your belly',
          'Lift head and tailbone',
          'Alternate 10 times slowly'
        ],
      );
  List<String> get ex3Benefits => _tList(
        [
          'Mobilise la colonne',
          'Soulage les lombalgies',
          'Améliore la flexibilité'
        ],
        ['يحرك العمود الفقري', 'يخفف آلام الظهر', 'يحسن المرونة'],
        ['Mobilizes the spine', 'Relieves back pain', 'Improves flexibility'],
      );

  // ============================================================
  // EXERCICE 4 : Respiration
  // ============================================================
  String get ex4Title =>
      _t('Respiration 4-4-4', 'التنفس 4-4-4', '4-4-4 Breathing');
  String get ex4Desc => _t(
        'Active le système nerveux parasympathique, réduit le stress.',
        'ينشط الجهاز العصبي السمبتاوي ويقلل التوتر.',
        'Activates the parasympathetic nervous system, reduces stress.',
      );
  List<String> get ex4Steps => _tList(
        [
          'Assis confortablement, dos droit',
          'Expirez complètement',
          'Inspirez par le nez, comptez 4',
          'Retenez le souffle, comptez 4',
          'Expirez lentement, comptez 4',
          'Répétez 4 cycles'
        ],
        [
          'اجلس بشكل مريح، ظهرك مستقيم',
          'ازفر تماماً',
          'شهق من الأنف، عدّ حتى 4',
          'احبس النفس، عدّ حتى 4',
          'ازفر ببطء، عدّ حتى 4',
          'كرر 4 دورات'
        ],
        [
          'Sit comfortably, back straight',
          'Exhale completely',
          'Inhale through nose, count to 4',
          'Hold your breath, count to 4',
          'Exhale slowly, count to 4',
          'Repeat 4 cycles'
        ],
      );
  List<String> get ex4Benefits => _tList(
        ['Réduit le stress', 'Améliore la concentration', 'Régule la tension'],
        ['يقلل التوتر', 'يحسن التركيز', 'ينظم ضغط الدم'],
        [
          'Reduces stress',
          'Improves concentration',
          'Regulates blood pressure'
        ],
      );

  // ============================================================
  // EXERCICE 5 : Marche
  // ============================================================
  String get ex5Title =>
      _t('Marche sur place', 'المشي في المكان', 'Walking in place');
  String get ex5Desc => _t(
        'Active la circulation et rompt la sédentarité prolongée.',
        'ينشط الدورة الدموية ويكسر الجلوس الطويل.',
        'Activates circulation and breaks prolonged sedentary behavior.',
      );
  List<String> get ex5Steps => _tList(
        [
          'Debout, pieds à largeur des épaules',
          'Levez le genou droit',
          'Posez, levez le genou gauche',
          'Balancez les bras naturellement',
          'Dos droit, regard devant',
          'Continuez 2 minutes'
        ],
        [
          'واقفاً، القدمان بعرض الكتفين',
          'ارفع الركبة اليمنى',
          'ضعها وارفع الركبة اليسرى',
          'حرك ذراعيك بشكل طبيعي',
          'ظهرك مستقيم، نظرك للأمام',
          'استمر دقيقتين'
        ],
        [
          'Stand with feet shoulder-width apart',
          'Lift your right knee',
          'Lower it, lift the left knee',
          'Swing your arms naturally',
          'Back straight, look ahead',
          'Continue for 2 minutes'
        ],
      );
  List<String> get ex5Benefits => _tList(
        ['Active la circulation', 'Renforce les jambes', 'Booste l\'énergie'],
        ['ينشط الدورة الدموية', 'يقوي الساقين', 'يزيد الطاقة'],
        ['Activates circulation', 'Strengthens legs', 'Boosts energy'],
      );

  // ============================================================
  // EXERCICE 6 : 20-20-20
  // ============================================================
  String get ex6Title =>
      _t('Règle 20-20-20', 'قاعدة 20-20-20', '20-20-20 Rule');
  String get ex6Desc => _t(
        'Réduit la fatigue oculaire causée par les écrans.',
        'يقلل إجهاد العين الناتج عن الشاشات.',
        'Reduces eye strain caused by screens.',
      );
  List<String> get ex6Steps => _tList(
        [
          'Toutes les 20 minutes',
          'Arrêtez de regarder l\'écran',
          'Trouvez un objet à 20 mètres',
          'Fixez-le 20 secondes',
          'Clignez des yeux plusieurs fois'
        ],
        [
          'كل 20 دقيقة',
          'توقف عن النظر في الشاشة',
          'ابحث عن شيء على بعد 20 متراً',
          'حدق فيه 20 ثانية',
          'رمش بعينيك عدة مرات'
        ],
        [
          'Every 20 minutes',
          'Stop looking at the screen',
          'Find an object 20 meters away',
          'Focus on it for 20 seconds',
          'Blink several times'
        ],
      );
  List<String> get ex6Benefits => _tList(
        [
          'Réduit la fatigue visuelle',
          'Prévient la myopie',
          'Soulage les maux de tête'
        ],
        ['يقلل إجهاد البصر', 'يمنع قصر النظر', 'يخفف الصداع'],
        ['Reduces eye strain', 'Prevents myopia', 'Relieves headaches'],
      );

  // ============================================================
  // EXERCICE 7 : Squats
  // ============================================================
  String get ex7Title =>
      _t('Squats assistés', 'القرفصاء المساعدة', 'Assisted squats');
  String get ex7Desc => _t(
        'Renforce quadriceps et fessiers sans risque de blessure.',
        'يقوي عضلات الفخذ والأرداف دون خطر الإصابة.',
        'Strengthens quads and glutes without injury risk.',
      );
  List<String> get ex7Steps => _tList(
        [
          'Debout devant une chaise',
          'Tendez les bras pour l\'équilibre',
          'Descendez en pliant les genoux',
          'Effleurez la chaise sans vous asseoir',
          'Remontez sur les talons',
          'Répétez 10 fois'
        ],
        [
          'واقفاً أمام كرسي',
          'مدّ ذراعيك للتوازن',
          'انزل بثني الركبتين',
          'لامس الكرسي دون الجلوس',
          'اصعد على الكعبين',
          'كرر 10 مرات'
        ],
        [
          'Stand in front of a chair',
          'Extend arms for balance',
          'Lower down by bending knees',
          'Lightly touch the chair without sitting',
          'Rise back up on your heels',
          'Repeat 10 times'
        ],
      );
  List<String> get ex7Benefits => _tList(
        [
          'Renforce les quadriceps',
          'Améliore l\'équilibre',
          'Active le métabolisme'
        ],
        ['يقوي عضلات الفخذ', 'يحسن التوازن', 'ينشط الأيض'],
        ['Strengthens quadriceps', 'Improves balance', 'Activates metabolism'],
      );

  // ============================================================
  // EXERCICE 8 : Planche
  // ============================================================
  String get ex8Title => _t('Gainage (Planche)', 'تمرين البلانك', 'Plank');
  String get ex8Desc => _t(
        'Renforce les muscles stabilisateurs de la colonne vertébrale.',
        'يقوي عضلات تثبيت العمود الفقري.',
        'Strengthens the stabilizing muscles of the spine.',
      );
  List<String> get ex8Steps => _tList(
        [
          'Allongez-vous face au sol',
          'Avant-bras au sol, coudes sous les épaules',
          'Soulevez le corps sur les orteils',
          'Corps aligné de la tête aux pieds',
          'Contractez abdos et fessiers',
          'Tenez le plus longtemps possible'
        ],
        [
          'استلقِ على البطن',
          'الساعدان على الأرض، الكوعان تحت الكتفين',
          'ارفع جسمك على أطراف القدمين',
          'الجسم مستقيم من الرأس للقدمين',
          'شدّ عضلات البطن والأرداف',
          'ابق أطول وقت ممكن'
        ],
        [
          'Lie face down',
          'Forearms on floor, elbows under shoulders',
          'Lift body on your toes',
          'Body aligned from head to feet',
          'Contract abs and glutes',
          'Hold as long as possible'
        ],
      );
  List<String> get ex8Benefits => _tList(
        [
          'Renforce le gainage',
          'Stabilise la colonne',
          'Améliore la posture globale'
        ],
        ['يقوي عضلات الجذع', 'يثبت العمود الفقري', 'يحسن الوضعية العامة'],
        [
          'Strengthens the core',
          'Stabilizes the spine',
          'Improves overall posture'
        ],
      );
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale l) => ['fr', 'ar', 'en'].contains(l.languageCode);
  @override
  Future<AppLocalizations> load(Locale l) async => AppLocalizations(l);
  @override
  // Retourne true si la locale a changé → force le rechargement des traductions
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
