import 'package:klaro/models/lesson.dart';

/// ============================================================
/// Sample Lessons (Hardcoded for Hackathon Demo)
/// ============================================================
/// These are pre-loaded lessons so we don't need a teacher upload feature.
/// In production, teachers would upload these via a web portal.

class SampleLessons {
  SampleLessons._();

  static final List<Lesson> lessons = [
    Lesson(
      id: 'lesson_001',
      title: 'The Water Cycle',
      subject: 'Science',
      gradeLevel: 'Grade 8',
      keyTerms: [
        'evaporation',
        'condensation',
        'precipitation',
        'transpiration',
        'water vapor',
        'atmosphere',
        'groundwater',
        'runoff',
      ],
      content: '''The Water Cycle

The water cycle, also known as the hydrological cycle, describes the continuous movement of water on, above, and below the surface of the Earth. Water is always changing states between liquid, vapor, and ice, and these changes are driven by energy from the sun.

Evaporation is the process by which liquid water changes into water vapor due to heat. When the sun heats the surface of oceans, rivers, and lakes, water molecules gain enough energy to escape into the atmosphere as invisible gas. This process is the primary way water moves from the Earth's surface into the atmosphere.

Transpiration is a similar process that occurs in plants. Plants absorb water from the soil through their roots, and this water travels up through the plant and evaporates from tiny pores on the leaves called stomata. Together, evaporation and transpiration are sometimes called evapotranspiration.

As water vapor rises into the atmosphere, it cools down. When the air becomes saturated with moisture, the water vapor undergoes condensation, turning back into tiny water droplets. These droplets cluster together around small particles of dust or pollen in the air, forming clouds. This is why you can see clouds in the sky — they are made of millions of tiny water droplets.

When clouds accumulate enough water droplets, the droplets combine and grow heavier. Eventually, they become too heavy to stay suspended in the air, and they fall back to Earth as precipitation. Precipitation can take many forms, including rain, snow, sleet, and hail, depending on the temperature of the atmosphere.

Once precipitation reaches the ground, it can follow several paths. Some water flows over the land surface as runoff, eventually reaching rivers, lakes, and oceans. Some water seeps into the ground and becomes groundwater, which can be stored in underground aquifers for thousands of years. Plants also absorb some of this water, continuing the cycle through transpiration.

The water cycle is essential for life on Earth. It distributes heat around the globe, provides fresh water for drinking and agriculture, and shapes the landscapes we see around us. Understanding the water cycle helps us appreciate how interconnected our planet's systems truly are.''',
    ),
    Lesson(
      id: 'lesson_002',
      title: 'Photosynthesis',
      subject: 'Science',
      gradeLevel: 'Grade 8',
      keyTerms: [
        'photosynthesis',
        'chlorophyll',
        'glucose',
        'carbon dioxide',
        'oxygen',
        'chloroplast',
        'sunlight',
        'stomata',
      ],
      content: '''Photosynthesis

Photosynthesis is the process by which green plants, algae, and some bacteria convert light energy from the sun into chemical energy stored in glucose. This process is fundamental to life on Earth because it produces the oxygen we breathe and the food that sustains most living organisms.

The process of photosynthesis takes place primarily in the leaves of plants, inside special cell structures called chloroplasts. Chloroplasts contain a green pigment called chlorophyll, which gives plants their green color. Chlorophyll is essential because it absorbs light energy from the sun, particularly red and blue wavelengths, and reflects green light — which is why plants appear green to our eyes.

The overall equation for photosynthesis can be written as: carbon dioxide plus water, in the presence of sunlight, produces glucose and oxygen. In chemical terms, six molecules of carbon dioxide and six molecules of water combine using light energy to produce one molecule of glucose and six molecules of oxygen.

Plants obtain carbon dioxide from the air through tiny openings on the underside of their leaves called stomata. These small pores can open and close to regulate the exchange of gases. Water is absorbed from the soil through the plant's roots and transported up to the leaves through a system of tubes called xylem.

Photosynthesis occurs in two main stages. The first stage, called the light-dependent reactions, takes place in the thylakoid membranes of the chloroplasts. During this stage, chlorophyll absorbs sunlight and uses the energy to split water molecules, releasing oxygen as a byproduct. The energy captured is stored in special molecules called ATP and NADPH.

The second stage, called the Calvin cycle or light-independent reactions, takes place in the stroma of the chloroplasts. During this stage, the ATP and NADPH produced in the first stage are used to convert carbon dioxide into glucose. This glucose serves as the primary energy source for the plant and can be used to build other important molecules like cellulose and starch.

Photosynthesis is crucial for maintaining the balance of gases in our atmosphere. Without photosynthesis, the oxygen levels in our atmosphere would decrease, and carbon dioxide levels would increase dramatically. This process also forms the base of most food chains, as animals either eat plants directly or eat other animals that feed on plants.''',
    ),
  ];

  /// Get a lesson by its ID
  static Lesson? getLessonById(String id) {
    try {
      return lessons.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }
}
