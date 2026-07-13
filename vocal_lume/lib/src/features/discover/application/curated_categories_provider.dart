import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/curated_category.dart';
import '../domain/curated_podcast.dart';

/// Static curated browse categories shown on the discover screen.
final curatedCategoriesProvider = Provider<List<CuratedCategory>>((ref) {
  return const [
    CuratedCategory(
      title: 'True Crime',
      subtitle: 'Gripping cases, investigations, and mysteries.',
      podcasts: [
        CuratedPodcast(
          title: 'Morbid',
          description:
              'Alaina Urquhart and Ash Kelley blend dark cases with humor.',
        ),
        CuratedPodcast(
          title: 'Rotten Mango',
          description:
              'Deep dives into bizarre and lesser-known true crime stories.',
        ),
        CuratedPodcast(
          title: 'My Favorite Murder',
          description:
              'Karen Kilgariff and Georgia Hardstark share favorite murder stories.',
        ),
        CuratedPodcast(
          title: 'Casefile True Crime',
          description:
              'Fact-based narration covering solved and unsolved cases.',
        ),
      ],
    ),
    CuratedCategory(
      title: 'Comedy / Variety',
      subtitle: 'Laughs, roasts, and unfiltered conversations.',
      podcasts: [
        CuratedPodcast(
          title: 'Matt and Shane\'s Secret Podcast',
          description:
              'Matt McCusker and Shane Gillis riff on culture and current events.',
        ),
        CuratedPodcast(
          title: 'Bad Friends',
          description:
              'Bobby Lee and Andrew Santino roast each other and welcome guests.',
        ),
        CuratedPodcast(
          title: 'Pardon My Take',
          description:
              'Barstool Sports\' flagship sports comedy show.',
        ),
        CuratedPodcast(
          title: 'Kill Tony',
          description:
              'Live stand-up showcase with one-minute sets and big guests.',
        ),
      ],
    ),
    CuratedCategory(
      title: 'Society & Culture',
      subtitle: 'Relationships, growth, and conversations about modern life.',
      podcasts: [
        CuratedPodcast(
          title: 'Call Her Daddy',
          description:
              'Alex Cooper on relationships, culture, and celebrity guests.',
        ),
        CuratedPodcast(
          title: 'Armchair Expert with Dax Shepard',
          description:
              'Dax Shepard explores the messiness of being human.',
        ),
        CuratedPodcast(
          title: 'On Purpose with Jay Shetty',
          description:
              'Purpose, mindfulness, and personal growth with Jay Shetty.',
        ),
      ],
    ),
    CuratedCategory(
      title: 'Science & Education',
      subtitle: 'Learn something new from researchers and storytellers.',
      podcasts: [
        CuratedPodcast(
          title: 'Huberman Lab',
          description:
              'Science-based tools for everyday life from Andrew Huberman.',
        ),
        CuratedPodcast(
          title: 'Stuff You Should Know',
          description:
              'Josh and Chuck explain how the world actually works.',
        ),
        CuratedPodcast(
          title: 'Lex Fridman Podcast',
          description:
              'Long-form conversations on science, tech, and philosophy.',
        ),
        CuratedPodcast(
          title: 'Science Vs',
          description:
              'Wendy Zukerman pits facts against fads and viral claims.',
        ),
      ],
    ),
    CuratedCategory(
      title: 'News & Politics',
      subtitle: 'Stay informed on the stories shaping the world.',
      podcasts: [
        CuratedPodcast(
          title: 'Pod Save America',
          description:
              'Former Obama staffers break down politics with insider perspective.',
        ),
        CuratedPodcast(
          title: 'The Ben Shapiro Show',
          description:
              'Conservative commentary on news, culture, and policy.',
        ),
        CuratedPodcast(
          title: 'Up First',
          description:
              'NPR\'s morning briefing on the three biggest stories of the day.',
        ),
        CuratedPodcast(
          title: 'The Journal.',
          description:
              'The Wall Street Journal on money, business, and power.',
        ),
      ],
    ),
    CuratedCategory(
      title: 'Historical & Deep Dives',
      subtitle: 'Well-researched stories from the past, told brilliantly.',
      podcasts: [
        CuratedPodcast(
          title: 'The Rest Is History',
          description:
              'Tom Holland and Dominic Sandbrook make history vivid and witty.',
        ),
        CuratedPodcast(
          title: 'Hardcore History',
          description:
              'Dan Carlin\'s epic deep dives into pivotal moments in history.',
        ),
        CuratedPodcast(
          title: 'Revisionist History',
          description:
              'Malcolm Gladwell re-examines overlooked events from the past.',
        ),
        CuratedPodcast(
          title: 'You\'re Dead to Me',
          description:
              'BBC history with a comedian and a historian.',
        ),
        CuratedPodcast(
          title: 'Throughline',
          description:
              'NPR traces how the past shapes the present.',
        ),
        CuratedPodcast(
          title: 'Dan Snow\'s History Hit',
          description:
              'Dan Snow interviews experts on the people and events that shaped our world.',
        ),
      ],
    ),
  ];
});
