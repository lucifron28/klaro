import 'package:klaro/models/curriculum.dart';
import 'package:klaro/models/lesson.dart';

/// Grade 7 curriculum data based on the DepEd LRMDS module list supplied for
/// the app. The hierarchy is Subject -> Module -> Lesson.
class SampleLessons {
  SampleLessons._();

  static final List<CurriculumSubject> subjects = [
    _subject(
      id: 'science_7',
      title: 'Science',
      description: 'Matter, living systems, energy, Earth, and space.',
      modules: const [
        _ModuleSeed(
          quarter: 'Quarter 1',
          title: 'Matter',
          lessons: [
            'Scientific Ways of Acquiring Knowledge and Solving Problems',
            'Elements Are Like Spices, When Mixed Together, They Become Better',
            'Two Worlds Apart: Pure Substances vs Mixtures',
            'I Have Less, She Has Ample, He Has More',
            'Quantity Really Matters',
          ],
        ),
        _ModuleSeed(
          quarter: 'Quarter 2',
          title: 'Living Things and Their Environment',
          lessons: [
            'The Microscope',
            'Life Through the Lens',
            'Levels of Biological Organization',
            'Eggs are White, Lemons are Yellow',
            'You and Me from Cells too Tiny',
            "Alone or Together, Let's Multiply for the Better",
            'Biotic and Abiotic Components of an Ecosystem',
            'Ecological Relationships',
            'Effects of Changes in the Abiotic Factors',
          ],
        ),
        _ModuleSeed(
          quarter: 'Quarter 3',
          title: 'Force, Motion and Energy',
          lessons: [
            "Let's Do The Motion",
            'Motion in Graphs and Dots',
            'The Waves',
            "It's Nice to HEAR You!",
            'Your Light is My Life!',
            "It's Getting Hot In Here!",
            'Be in Charge! Be Electrifying!',
          ],
        ),
        _ModuleSeed(
          quarter: 'Quarter 4',
          title: 'Earth and Space',
          lessons: [
            'Locating Places of the Earth',
            'Mission Possible: Saving Planet Earth',
            'You Keep Me Warm',
            'Rise Above, Sink Below, and Blow Around',
            "Behind the Length of Daytime is the Tilt of the Earth's Axis",
            'The Reason for the Seasons',
            'Earth around the Sun',
            'A Shining, Shimmering, Splendid Light in the Sky',
            'Coordinates and Me',
            'Lights On or Lights Off?',
          ],
        ),
      ],
    ),
    _subject(
      id: 'english_7',
      title: 'English',
      description: 'Reading, listening, speaking, viewing, and writing skills.',
      modules: const [
        _ModuleSeed(
          quarter: 'Quarter 1',
          title: 'Reading Comprehension, Vocabulary, Grammar',
          lessons: [
            'Analogy',
            'Genres of Viewing',
            'Active and Passive Voices',
            'Simple Past Tense',
            'Past Perfect Tense',
            'Direct and Reported Speeches',
            'Using Phrases Appropriately and Meaningfully',
            'Using Clauses Appropriately and Meaningfully',
            'Using Sentences Appropriately and Meaningfully',
            "Reading Style for One's Purpose",
          ],
        ),
        _ModuleSeed(
          quarter: 'Quarter 2',
          title: 'Listening Comprehension',
          lessons: [
            'Use Listening Strategies Based on Purpose, Familiarity with the Topic and Levels of Difficulty',
            'The Search Engine',
            'Information Sources',
            'Extracting Information using a Summary, a Precis and Paraphrase',
            'Print and Broadcast Media',
            'Word Analogies',
            'Linear and Non-Linear Texts',
          ],
        ),
        _ModuleSeed(
          quarter: 'Quarter 3',
          title: 'Oral Language and Fluency',
          lessons: [
            'Multimedia Resources for Oral Communication',
            'Basic Factors of Delivery',
            'Recognizing My Strength',
            "Express One's Beliefs/Convictions Based on a Material Viewed",
            'Cite Evidence to Support a General Statement',
            'Statements of Fact and Opinion',
            'Asking Wh-Questions',
          ],
        ),
        _ModuleSeed(
          quarter: 'Quarter 4',
          title: 'Writing and Composition',
          lessons: [
            'The Features of Academic Writing',
            'Strategies for Effective Interpersonal Communication',
            'Determine the Worth of Ideas Mentioned in the Text Listened to',
            'Discover The Conflicts Presented in Literary Selections',
            'Determining the Truthfulness and Accuracy of the Materials Viewed',
            "Discover Literature as a Tool to Assert One's Unique Identity",
            'Discover Through Philippine Literature The Need To Work Cooperatively',
            'Informative Essay',
          ],
        ),
      ],
    ),
    _subject(
      id: 'mathematics_7',
      title: 'Mathematics',
      description: 'Numbers, measurement, algebra, geometry, and statistics.',
      modules: const [
        _ModuleSeed(
          quarter: 'Quarter 1',
          title: 'Numbers and Number Sense',
          lessons: [
            'Sets',
            'Problems Involving Sets',
            'Absolute Value and Operations on Integers',
            'Properties of Operations on the Set of Integers',
            'Expressing Rational Numbers from Fraction Form to Decimal Form and Vice-versa',
            'Operations on Rational Numbers',
            'Principal Roots and Irrational Numbers',
            'Estimating the Square Roots of Whole Numbers and Plotting Irrational Numbers',
            'Subsets of Real Numbers',
            'Scientific Notations and Solving Problems Involving Real Numbers',
          ],
        ),
        _ModuleSeed(
          quarter: 'Quarter 2',
          title: 'Measurement and Algebra',
          lessons: [
            'Approximating Measurement',
            'Solving Problems Involving Conversion of Units',
            'Translating English Phrases and Sentences to Mathematical Phrases and Sentences',
            'Algebraic Expressions',
            'Operations Involving Polynomials',
            'Special Products',
            'Solving Problems Involving Algebraic Expressions',
            'Algebraic Expressions, Linear Equations and Inequalities',
            'Solving Linear Equations and Inequalities in One Variable',
          ],
        ),
        _ModuleSeed(
          quarter: 'Quarter 3',
          title: 'Geometry',
          lessons: [
            'Basic Concepts and Terms in Geometry',
            'Angles',
            'Parallel Lines Cut by Transversal',
            'Geometric Construction: Bisectors, Perpendicular Lines and Parallel Lines',
            'Module 5 not available in LRMDS',
            'Circles',
            'Construct Triangles, Squares, Rectangles, Regular Pentagons, and Regular Hexagons',
            'Solving Problems Involving Side and Angle of a Polygon',
          ],
        ),
        _ModuleSeed(
          quarter: 'Quarter 4',
          title: 'Statistics and Probability',
          lessons: [
            'Real-Life Problems that can be Solved by Statistics',
            'Data Gathering and Organizing',
            'Presentation of Data',
            'Measures of Central Tendency',
            'Measures of Variability',
            'Analysis and Interpretation of Statistical Data',
          ],
        ),
      ],
    ),
  ];

  static final List<Lesson> lessons =
      subjects.expand((subject) => subject.lessons).toList(growable: false);

  static CurriculumSubject? getSubjectById(String id) {
    try {
      return subjects.firstWhere((subject) => subject.id == id);
    } catch (_) {
      return null;
    }
  }

  static CurriculumModule? getModuleById(String id) {
    for (final subject in subjects) {
      for (final module in subject.modules) {
        if (module.id == id) return module;
      }
    }
    return null;
  }

  static Lesson? getLessonById(String id) {
    try {
      return lessons.firstWhere((lesson) => lesson.id == id);
    } catch (_) {
      return null;
    }
  }

  static CurriculumSubject _subject({
    required String id,
    required String title,
    required String description,
    required List<_ModuleSeed> modules,
  }) {
    const gradeLevel = 'Grade 7';
    final builtModules = modules.asMap().entries.map((entry) {
      return _module(
        subjectId: id,
        subjectTitle: title,
        gradeLevel: gradeLevel,
        seed: entry.value,
        quarterNumber: entry.key + 1,
      );
    }).toList(growable: false);

    return CurriculumSubject(
      id: id,
      title: title,
      gradeLevel: gradeLevel,
      description: description,
      modules: builtModules,
    );
  }

  static CurriculumModule _module({
    required String subjectId,
    required String subjectTitle,
    required String gradeLevel,
    required _ModuleSeed seed,
    required int quarterNumber,
  }) {
    final moduleId = '${subjectId}_q$quarterNumber';
    final lessons = seed.lessons.asMap().entries.map((entry) {
      return _lesson(
        subjectTitle: subjectTitle,
        gradeLevel: gradeLevel,
        moduleId: moduleId,
        moduleTitle: seed.title,
        quarter: seed.quarter,
        lessonTitle: entry.value,
        lessonNumber: entry.key + 1,
      );
    }).toList(growable: false);

    return CurriculumModule(
      id: moduleId,
      subjectId: subjectId,
      subjectTitle: subjectTitle,
      gradeLevel: gradeLevel,
      quarter: seed.quarter,
      title: seed.title,
      description: '${seed.quarter}: ${seed.title}',
      lessons: lessons,
    );
  }

  static Lesson _lesson({
    required String subjectTitle,
    required String gradeLevel,
    required String moduleId,
    required String moduleTitle,
    required String quarter,
    required String lessonTitle,
    required int lessonNumber,
  }) {
    final id = '${moduleId}_l${lessonNumber.toString().padLeft(2, '0')}';

    return Lesson(
      id: id,
      title: lessonTitle,
      subject: subjectTitle,
      gradeLevel: gradeLevel,
      moduleId: moduleId,
      moduleTitle: moduleTitle,
      quarter: quarter,
      keyTerms: const [],
      content: _buildContent(
        subjectTitle: subjectTitle,
        gradeLevel: gradeLevel,
        moduleTitle: moduleTitle,
        quarter: quarter,
        lessonTitle: lessonTitle,
      ),
    );
  }

  static String _buildContent({
    required String subjectTitle,
    required String gradeLevel,
    required String moduleTitle,
    required String quarter,
    required String lessonTitle,
  }) {
    if (lessonTitle.toLowerCase().contains('not available')) {
      return '''$lessonTitle

The official learning material for this module slot is currently not available in the LRMDS curriculum list. This placeholder ensures the sequence matches official module numbering. 

Once the official curriculum content is released, it will be updated here to provide the full lesson details and learning objectives.''';
    }

    return _generateRealisticLessonContent(
      subjectTitle: subjectTitle,
      moduleTitle: moduleTitle,
      lessonTitle: lessonTitle,
    );
  }

  static String _generateRealisticLessonContent({
    required String subjectTitle,
    required String moduleTitle,
    required String lessonTitle,
  }) {
    final subject = subjectTitle.toLowerCase();
    final lesson = lessonTitle.toLowerCase();

    if (subject == 'science') {
      // Quarter 1: Matter
      if (lesson.contains('acquiring knowledge') || lesson.contains('scientific ways')) {
        return '''Science is a systematic way of acquiring knowledge about the natural world through observation and experimentation. The scientific method involves identifying a problem, gathering data, forming a hypothesis, and conducting experiments to test that hypothesis. 

By following these steps, scientists can reach evidence-based conclusions. Critical thinking and curiosity are at the heart of this process, allowing us to solve complex problems and discover new facts about our environment.''';
      }
      if (lesson.contains('elements are like spices') || lesson.contains('compound')) {
        return '''Elements are pure substances that consist of only one type of atom. They are the simplest forms of matter and are represented by chemical symbols like O for Oxygen and Au for Gold. When elements are chemically combined in fixed proportions, they form compounds.

Compounds, such as water (H2O) or table salt (NaCl), have properties that are different from the elements they are made of. Just as different spices give flavor to a dish, elements combine in various ways to create the incredible variety of substances we see in the world around us.''';
      }
      if (lesson.contains('pure substances vs mixtures') || lesson.contains('two worlds apart')) {
        return '''Matter can be classified into two broad categories: pure substances and mixtures. A pure substance has a uniform and definite composition, meaning every sample of it has the same properties. This includes both elements and compounds.

Mixtures, however, are physical combinations of two or more substances where each substance retains its own chemical identity. Mixtures can be homogeneous, like air, or heterogeneous, like a salad. Understanding the differences between these two worlds is fundamental to studying how matter interacts.''';
      }
      if (lesson.contains('i have less') || lesson.contains('solutions') || lesson.contains('concentration')) {
        return '''A solution is a homogeneous mixture where one substance (the solute) is dissolved in another (the solvent). The concentration of a solution tells us how much solute is present in a given amount of solvent. 

If a solution has a small amount of solute, it is described as dilute. If it has a large amount, it is concentrated. Common examples include salt water or sugar dissolved in tea. Knowing how to measure and adjust concentration is vital in fields ranging from cooking to medicine.''';
      }
      if (lesson.contains('quantity really matters') || lesson.contains('saturated')) {
        return '''Solubility is the maximum amount of a solute that can dissolve in a specific amount of solvent at a certain temperature. When a solution can no longer dissolve any more solute, it is called a saturated solution.

If the solution can still dissolve more solute, it is unsaturated. In some cases, by heating a solvent, we can create a supersaturated solution that holds more solute than normal. The quantity of solute really matters because it determines the physical properties and stability of the mixture.''';
      }

      // Quarter 2: Living Things
      if (lesson == 'the microscope') {
        return '''The microscope is a tool used by scientists to observe objects that are too small to be seen by the naked eye. It has several key parts, including the eyepiece, objective lenses, stage, and light source. The lenses work together to magnify the specimen, while the knobs allow for fine and coarse focusing.

Proper care is essential when using a microscope. It should always be carried with two hands and cleaned only with special lens paper. By mastering this instrument, we can unlock the secrets of the microscopic world, from the structure of a single cell to the tiny organisms living in a drop of water.''';
      }
      if (lesson.contains('life through the lens')) {
        return '''Viewing life through the lens of a microscope reveals a world of complexity that is otherwise hidden. To see a specimen clearly, it must be properly prepared on a slide, often using a thin slice of material and sometimes a stain to highlight specific structures.

As we increase the magnification, our field of view becomes smaller but the level of detail increases. This perspective allows us to see the building blocks of life in action, helping us understand how biological structures function at the most basic level.''';
      }
      if (lesson.contains('levels of biological organization')) {
        return '''Living things are organized into levels of increasing complexity. It begins with the cell, the basic unit of life. A group of similar cells working together forms a tissue. Multiple tissues working together create an organ, such as the heart or a leaf.

A group of organs that perform a specific function makes up an organ system, and all these systems together form an organism. This hierarchy continues upward to populations, communities, and ecosystems. Understanding these levels helps us see how every part of a living system contributes to the survival of the whole.''';
      }
      if (lesson.contains('eggs are white') || lesson.contains('plant vs animal cells')) {
        return '''While all cells share some common features, there are significant differences between plant and animal cells. Plant cells have a rigid cell wall and chloroplasts for photosynthesis, which animal cells lack. Plant cells also typically have one large central vacuole, while animal cells have smaller, temporary ones.

Both types of cells contain a nucleus, cytoplasm, and a cell membrane. These structures are the microscopic "organs" of the cell, each performing a vital task to keep the organism alive and healthy.''';
      }
      if (lesson.contains('cells too tiny')) {
        return '''Every living thing on Earth, from the largest whale to the smallest blade of grass, is made of cells. Cell theory states that all organisms are composed of one or more cells, the cell is the basic unit of life, and all cells come from pre-existing cells.

Because cells are so tiny, they were only discovered after the invention of the microscope. Despite their small size, they carry out all the complex processes needed for life, including energy production, growth, and reproduction.''';
      }
      if (lesson.contains('multiply for the better') || lesson.contains('reproduction')) {
        return '''Reproduction is the biological process by which new individual organisms are produced. It can be asexual, involving only one parent and resulting in offspring that are genetically identical to the parent. Examples include budding in yeast or fragmentation in starfish.

Sexual reproduction involves two parents and the fusion of specialized cells, leading to offspring with a unique genetic mix. Both methods ensure the continuation of a species and play a vital role in the diversity and evolution of life on Earth.''';
      }
      if (lesson.contains('biotic and abiotic') || lesson.contains('ecosystem components')) {
        return '''An ecosystem is made up of two interacting components: biotic and abiotic. Biotic components are the living parts of the environment, such as plants, animals, fungi, and bacteria. Abiotic components are the non-living factors, including sunlight, water, soil, air, and temperature.

The balance of an ecosystem depends on the constant interaction between these two groups. For example, plants (biotic) need sunlight and water (abiotic) to grow, and in turn, they provide food and oxygen for animals.''';
      }
      if (lesson.contains('ecological relationships')) {
        return '''In an ecosystem, organisms interact with each other in various ways called ecological relationships. These include predation, where one organism hunts another, and competition, where organisms vie for the same resources. 

Symbiosis describes closer relationships, such as mutualism (both benefit), commensalism (one benefits, the other is unaffected), and parasitism (one benefits at the expense of the other). These interactions shape the structure of communities and ensure the flow of energy through the environment.''';
      }
      if (lesson.contains('changes in the abiotic factors')) {
        return '''Abiotic factors like temperature, rainfall, and soil quality are not constant; they can change due to seasons, climate shifts, or human activity. These changes can have profound effects on the biotic community.

For example, a decrease in rainfall can lead to drought, affecting plant growth and the animals that depend on them. Organisms must either adapt to these changes, move to a new location, or face the risk of extinction. Protecting the stability of abiotic factors is crucial for the health of our planet.''';
      }

      // Quarter 3: Force, Motion and Energy
      if (lesson.contains('lets do the motion') || lesson == 'distance and displacement') {
        return '''Motion is defined as a change in position relative to a reference point. To describe motion, we use terms like distance and displacement. Distance is the total path length traveled by an object, while displacement is the straight-line distance between the starting and ending points, including direction.

By measuring how far an object goes and how long it takes, we can calculate its speed. Understanding these basic concepts allows us to track the movement of everything from a person walking to a planet orbiting the Sun.''';
      }
      if (lesson.contains('graphs and dots') || lesson.contains('velocity')) {
        return '''We can visualize motion using various tools like motion graphs and ticker-tape diagrams (the "dots"). A distance-time graph shows how far an object has moved over time, where the slope of the line represents the speed.

A ticker-tape timer leaves dots on a strip of paper as an object moves; if the dots are evenly spaced, the speed is constant. If the spacing increases, the object is accelerating. These visual representations make it easier to analyze complex movements and predict future positions.''';
      }
      if (lesson.contains('the waves')) {
        return '''A wave is a disturbance that travels through a medium or vacuum, carrying energy without transporting matter. Mechanical waves, like sound and water waves, require a medium to travel through. Electromagnetic waves, like light, can travel through empty space.

Waves are classified as transverse, where the particles move perpendicular to the direction of the wave, or longitudinal, where they move parallel. Every wave has properties like wavelength, frequency, and amplitude, which determine how much energy it carries.''';
      }
      if (lesson.contains('hear') || lesson.contains('sound')) {
        return '''Sound is a longitudinal wave produced by vibrating objects. These vibrations create regions of high and low pressure that travel through air, water, or solids to reach our ears. The pitch of a sound is determined by its frequency—the number of vibrations per second.

The loudness of a sound depends on the amplitude of the wave. Sound travels at different speeds depending on the material it is passing through, moving fastest in solids and slowest in gases. Understanding sound helps us communicate, enjoy music, and use technology like sonar.''';
      }
      if (lesson.contains('light') || lesson.contains('reflection')) {
        return '''Light is a form of electromagnetic energy that allows us to see the world. It travels in straight lines until it hits an object, where it can be reflected, absorbed, or refracted. Reflection is what happens when light bounces off a surface, like a mirror.

Refraction is the bending of light as it passes from one material to another, such as from air into water. White light is actually a mixture of many colors, which can be seen when it passes through a prism to create a rainbow. Light is essential for photosynthesis and many technologies we use every day.''';
      }
      if (lesson.contains('hot') || lesson.contains('heat') || lesson.contains('temperature')) {
        return '''Heat is a form of energy that moves from a warmer object to a cooler one. This transfer happens through three main processes: conduction (through direct contact), convection (through fluids like air or water), and radiation (through electromagnetic waves).

Temperature is a measure of the average kinetic energy of the particles in a substance. While heat is the energy being transferred, temperature tells us how hot or cold an object is. Understanding heat transfer is key to everything from cooking our food to understanding weather patterns.''';
      }
      if (lesson.contains('charge') || lesson.contains('electr')) {
        return '''Electricity is a form of energy resulting from the movement of charged particles, like electrons. It can exist as static electricity (buildup of charges) or as current electricity (the flow of charges through a conductor). 

A basic electric circuit requires a power source, a conductor, and a load like a light bulb. Materials that allow electricity to flow easily are called conductors, while those that block it are insulators. Electricity powers our homes, schools, and the digital devices we rely on every day.''';
      }

      // Quarter 4: Earth and Space
      if (lesson.contains('locating places') || lesson.contains('coordinates')) {
        return '''To find any location on Earth, we use a grid system of imaginary lines called latitude and longitude. Latitude lines run east-west and measure distance north or south of the Equator. Longitude lines run north-south and measure distance east or west of the Prime Meridian.

By combining these two coordinates, we can identify a unique point on the globe. This system is essential for navigation, map-making, and the GPS technology used in smartphones and vehicles.''';
      }
      if (lesson.contains('saving planet earth') || lesson.contains('resources')) {
        return '''Planet Earth provides us with many natural resources, such as water, air, soil, minerals, and forests. These can be renewable (like sunlight and wind) or non-renewable (like coal and oil). Protecting these resources is essential for the survival of all living things.

Sustainability means using resources in a way that meets our needs without compromising the ability of future generations to meet theirs. By reducing waste, recycling, and using energy efficiently, we can fulfill the "mission possible" of saving our planet for the future.''';
      }
      if (lesson.contains('warm') || lesson.contains('atmosphere')) {
        return '''The atmosphere is the layer of gases surrounding Earth that makes life possible. it protects us from harmful solar radiation, keeps the planet warm through the greenhouse effect, and provides the oxygen we breathe. The atmosphere is divided into layers, including the troposphere where weather happens and the stratosphere which contains the ozone layer.

Maintaining the balance of these gases is crucial. Human activities, such as burning fossil fuels, can increase greenhouse gases and lead to global warming, which changes our climate and affects ecosystems worldwide.''';
      }
      if (lesson.contains('rise above') || lesson.contains('breeze') || lesson.contains('wind')) {
        return '''Wind is the movement of air caused by differences in air pressure, which are often the result of uneven heating of the Earth's surface. Warm air is less dense and rises, while cooler, denser air sinks and moves in to take its place.

Local wind systems include sea breezes (blowing from sea to land during the day) and land breezes (blowing from land to sea at night). On a larger scale, monsoons are seasonal wind patterns that bring significant changes in weather and rainfall to regions like the Philippines.''';
      }
      if (lesson.contains('length of daytime') || lesson.contains('tilt of the earth')) {
        return '''The tilt of the Earth's axis (about 23.5 degrees) is responsible for the changing length of daytime throughout the year. As Earth revolves around the Sun, different parts of the planet are tilted toward or away from it.

When a hemisphere is tilted toward the Sun, it experiences longer days and shorter nights. When it is tilted away, the opposite occurs. This tilt is the fundamental reason why the amount of sunlight we receive changes, impacting everything from plant growth to our daily schedules.''';
      }
      if (lesson.contains('reason for the seasons')) {
        return '''Seasons are the result of Earth's axial tilt and its revolution around the Sun. They are not caused by the distance between Earth and the Sun, which remains relatively constant. Instead, the tilt determines the angle at which sunlight hits different parts of the Earth.

During summer, sunlight hits more directly, providing more heat. In winter, the light is more slanted and spread out, making it cooler. While tropical countries like the Philippines mainly have wet and dry seasons, the underlying cause is still the Earth's movement and tilt in space.''';
      }
      if (lesson.contains('earth around the sun') || lesson.contains('orbit')) {
        return '''Earth travels around the Sun in a nearly circular path called an orbit. This journey, known as revolution, takes about 365.25 days to complete, giving us our calendar year. At the same time, Earth is rotating on its axis, which gives us our 24-hour day.

The combination of rotation and revolution governs our cycles of light and dark, heat and cold. This constant movement in space is what creates the stable environment needed for life to thrive on our planet.''';
      }
      if (lesson.contains('sky') || lesson.contains('light in the sky') || lesson.contains('eclipse')) {
        return '''The sky holds many wonders, including celestial events like solar and lunar eclipses. An eclipse happens when one heavenly body moves into the shadow of another. A solar eclipse occurs when the Moon passes between Earth and the Sun, blocking the Sun's light.

A lunar eclipse happens when Earth passes between the Sun and the Moon, casting a shadow on the Moon. These rare and beautiful events allow us to observe the alignment of our solar system and have been studied by astronomers for thousands of years.''';
      }

      return '''This lesson explores fundamental concepts in Science, focusing on observation and evidence-based reasoning. Students learn to analyze the world around them by identifying patterns, conducting experiments, and drawing conclusions based on scientific data. 

Whether studying the smallest particles of matter or the vast systems of the Earth, the goal is to develop a deeper understanding of how the natural world functions and how we can interact with it responsibly.''';
    }

    if (subject == 'english') {
      if (lesson.contains('grammar') || lesson.contains('tense') || lesson.contains('voice') || lesson.contains('speech') || lesson.contains('sentence') || lesson.contains('phrase') || lesson.contains('clause')) {
        return '''Effective communication in English relies on a strong foundation of grammar and sentence structure. Understanding the difference between active and passive voices helps writers choose the best way to emphasize the performer or the action. Tenses, such as the simple past and past perfect, allow us to accurately describe the timing of events in a narrative.

By mastering the use of phrases and clauses, we can build more complex and meaningful sentences. Direct and reported speech are also essential for sharing information and stories clearly. Practicing these skills ensures that our writing and speaking are both accurate and engaging for our audience.''';
      }
      if (lesson.contains('reading') || lesson.contains('listening') || lesson.contains('comprehension') || lesson.contains('summary') || lesson.contains('paraphrase') || lesson.contains('strategy')) {
        return '''Reading and listening are active processes that require specific strategies to be effective. Depending on our purpose, we might skim a text for the main idea or scan it for specific details. Extracting information through summaries, précis, and paraphrasing helps us process and remember what we've learned.

In today's digital age, being able to navigate search engines and evaluate different information sources—both print and broadcast—is a vital skill. By analyzing analogies and understanding linear and non-linear texts, we can deepen our comprehension and become more critical consumers of media.''';
      }
      if (lesson.contains('oral') || lesson.contains('delivery') || lesson.contains('belief') || lesson.contains('opinion') || lesson.contains('fact') || lesson.contains('multimedia')) {
        return '''Oral communication involves more than just words; it includes factors of delivery like volume, pitch, and body language. Using multimedia resources can enhance our presentations and help us express our beliefs and convictions more effectively. In any discussion, it is important to distinguish between statements of fact and opinion.

Citing evidence to support a general statement strengthens our arguments and builds credibility. By asking strong "Wh-" questions, we can engage more deeply with others and uncover new perspectives. Developing these oral skills helps us communicate with confidence in both academic and social settings.''';
      }
      if (lesson.contains('writing') || lesson.contains('essay') || lesson.contains('literature') || lesson.contains('academic')) {
        return '''Academic writing has specific features that distinguish it from casual communication, such as a formal tone and a clear structure. Writing an informative essay requires organizing ideas logically and providing accurate details to explain a topic. Literature serves as a powerful tool to explore unique identities and the need for cooperative work.

Through the study of Philippine literature, we discover stories that reflect our culture and values. Effective interpersonal communication strategies also play a role in how we collaborate on writing projects and share our ideas with the world. Mastering these forms of composition allows us to express complex thoughts with clarity and impact.''';
      }
      return '''This lesson focuses on developing core English language skills across reading, writing, speaking, and listening. Students engage with various texts and media to improve their vocabulary, grammar, and critical thinking.

By practicing these communication strategies, learners become more proficient in expressing themselves clearly and understanding the messages of others in a variety of contexts.''';
    }

    if (subject == 'mathematics') {
      if (lesson.contains('set') || lesson.contains('integer') || lesson.contains('rational') || lesson.contains('number') || lesson.contains('absolute') || lesson.contains('root')) {
        return '''Numbers are the building blocks of mathematics. We use sets to group objects and solve problems involving relationships between different categories. Integers, which include positive and negative whole numbers, are essential for representing concepts like temperature, debt, and elevation.

Rational numbers can be expressed as fractions or decimals, and understanding how to convert between them is a key skill. Operations on these numbers follow specific properties that allow us to simplify expressions and solve real-world problems. Whether using scientific notation or estimating roots, a strong number sense is the foundation for all higher mathematics.''';
      }
      if (lesson.contains('algebra') || lesson.contains('expression') || lesson.contains('equation') || lesson.contains('inequalities') || lesson.contains('polynomial')) {
        return '''Algebra is a branch of mathematics that uses symbols and letters to represent numbers in expressions and equations. By translating English phrases into mathematical phrases, we can model real-life situations and find unknown values. Operations involving polynomials and special products allow us to manipulate these expressions efficiently.

Solving linear equations and inequalities in one variable is a fundamental skill used in everything from budgeting to engineering. Understanding how to maintain the balance of an equation while isolating a variable is the key to finding solutions and making accurate predictions.''';
      }
      if (lesson.contains('geometry') || lesson.contains('angle') || lesson.contains('line') || lesson.contains('circle') || lesson.contains('polygon') || lesson.contains('triangle') || lesson.contains('construction')) {
        return '''Geometry is the study of shapes, sizes, and the properties of space. It begins with basic concepts like points, lines, and planes, and extends to more complex structures like polygons and circles. Angles play a crucial role in defining the relationships between lines, especially when parallel lines are cut by a transversal.

Geometric construction—using tools like a compass and straightedge—allows us to create precise bisectors and perpendicular lines. By understanding the side and angle relationships in triangles and other polygons, we can solve problems in architecture, design, and navigation.''';
      }
      if (lesson.contains('statistics') || lesson.contains('data') || lesson.contains('tendency') || lesson.contains('variability') || lesson.contains('probability')) {
        return '''Statistics is the science of gathering, organizing, and interpreting data to make informed decisions. We use measures of central tendency—mean, median, and mode—to find the typical value in a data set. Measures of variability, like range and standard deviation, tell us how spread out the data is.

Presenting data through tables and graphs makes it easier to identify trends and patterns. By analyzing and interpreting statistical data, we can solve real-life problems and understand the probability of different outcomes. These skills are essential for everything from scientific research to business planning.''';
      }
      return '''This lesson covers fundamental mathematical principles and their practical applications. Students develop problem-solving skills by applying logical reasoning and mathematical operations to various scenarios.

By mastering these concepts, learners build a toolkit of techniques for analyzing quantitative information and solving complex problems in both academic and everyday life.''';
    }

    return '''This lesson provides foundational knowledge on the topic, focusing on key concepts and their practical applications. Students are encouraged to explore the material, identify core principles, and apply what they have learned to solve problems and understand the world around them.

Through active engagement and practice, learners will build a strong understanding of this subject area and be prepared for more advanced studies in the future.''';
  }


}

class _ModuleSeed {
  final String quarter;
  final String title;
  final List<String> lessons;

  const _ModuleSeed({
    required this.quarter,
    required this.title,
    required this.lessons,
  });
}
