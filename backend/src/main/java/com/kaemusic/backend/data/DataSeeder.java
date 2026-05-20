package com.kaemusic.backend.data;

import com.kaemusic.backend.data.entities.Track;
import com.kaemusic.backend.data.repositories.TrackRepository;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class DataSeeder {

    private static final Logger log = LoggerFactory.getLogger(DataSeeder.class);

    private final TrackRepository trackRepository;

    public DataSeeder(TrackRepository trackRepository) {
        this.trackRepository = trackRepository;
    }

    @PostConstruct
    public void seedTracks() {
        if (trackRepository.count() > 0) {
            log.info("Track data already exists. Skipping seeder.");
            return;
        }

        List<Track> tracks = List.of(
                Track.builder()
                        .title("Synth Odyssey")
                        .artist("The Midnight")
                        .album("Endless Summer")
                        .genre("Electronic")
                        .durationSeconds(214)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400")
                        .build(),
                Track.builder()
                        .title("Neon Lights")
                        .artist("Daft Punk")
                        .album("Random Access Memories")
                        .genre("Electronic")
                        .durationSeconds(269)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400")
                        .build(),
                Track.builder()
                        .title("Golden Hour")
                        .artist("JVKE")
                        .album("This Is What Golden Hour Feels Like")
                        .genre("Pop")
                        .durationSeconds(198)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1506157786151-b8491531f063?w=400")
                        .build(),
                Track.builder()
                        .title("Blinding City")
                        .artist("Weeknd Style")
                        .album("After Hours")
                        .genre("R&B")
                        .durationSeconds(241)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400")
                        .build(),
                Track.builder()
                        .title("Orbit Dreams")
                        .artist("Bonobo")
                        .album("Migration")
                        .genre("Chillout")
                        .durationSeconds(307)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1462965326201-d02e4f455804?w=400")
                        .build(),
                Track.builder()
                        .title("Frequency")
                        .artist("Tycho")
                        .album("Epoch")
                        .genre("Ambient")
                        .durationSeconds(223)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400")
                        .build(),
                Track.builder()
                        .title("Retrowave")
                        .artist("FM-84")
                        .album("Atlas")
                        .genre("Synthwave")
                        .durationSeconds(255)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1504898770365-14faca6a7320?w=400")
                        .build(),
                Track.builder()
                        .title("Deep Current")
                        .artist("Aphex Twin")
                        .album("Selected Ambient Works")
                        .genre("IDM")
                        .durationSeconds(334)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1446057032654-9d8885db76c6?w=400")
                        .build(),
                Track.builder()
                        .title("Summer Pulse")
                        .artist("Kygo")
                        .album("Cloud Nine")
                        .genre("Tropical House")
                        .durationSeconds(187)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400")
                        .build(),
                Track.builder()
                        .title("Midnight Jazz")
                        .artist("Norah Jones")
                        .album("Come Away With Me")
                        .genre("Jazz")
                        .durationSeconds(276)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=400")
                        .build(),
                Track.builder()
                        .title("Electric Soul")
                        .artist("Dua Lipa")
                        .album("Future Nostalgia")
                        .genre("Dance Pop")
                        .durationSeconds(203)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400")
                        .build(),
                Track.builder()
                        .title("Canyon Echo")
                        .artist("Explosions In The Sky")
                        .album("The Earth Is Not a Cold Dead Place")
                        .genre("Post-Rock")
                        .durationSeconds(412)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1433086966358-54859d0ed716?w=400")
                        .build(),
                Track.builder()
                        .title("Velvet Underground")
                        .artist("Tame Impala")
                        .album("Currents")
                        .genre("Psychedelic Rock")
                        .durationSeconds(289)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=400")
                        .build(),
                Track.builder()
                        .title("Solar Wind")
                        .artist("Boards of Canada")
                        .album("Music Has the Right to Children")
                        .genre("Downtempo")
                        .durationSeconds(318)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1464802686167-b939a6910659?w=400")
                        .build(),
                Track.builder()
                        .title("Pulse City")
                        .artist("Flume")
                        .album("Skin")
                        .genre("Future Bass")
                        .durationSeconds(231)
                        .streamUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3")
                        .coverArtUrl("https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=400")
                        .build()
        );

        trackRepository.saveAll(tracks);
        log.info("Successfully seeded 15 tracks into the database.");
    }
}
