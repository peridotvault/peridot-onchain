import React, { useEffect, useRef, useState } from 'react';
import GlassComponent from '../components/atoms/GlassComponent';
import ElasticSlider from '../components/atoms/ElasticSlider';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
    faPlay, faPause, faStop,
    faForwardStep, faBackwardStep,
    faVolumeOff, faVolumeHigh, faRepeat
} from '@fortawesome/free-solid-svg-icons';

export const Music = () => {
    // 1) Playlist: tinggal tambah/kurangi di sini
    const PLAYLIST = [
        { title: 'Vault Theme', src: '/assets/music/vault.mp3' },
        { title: 'Arena', src: '/assets/music/arena.mp3' },
        { title: 'Nebula', src: '/assets/music/nebula.mp3' },
    ];

    // 2) States
    const [index, setIndex] = useState(0);
    const [isPlaying, setIsPlaying] = useState(false);
    const [playInLoop, setPlayInLoop] = useState(false);
    const [volume, setVolume] = useState(0.7); // 0.0 - 1.0

    // 3) Single audio element (persist)
    const audioRef = useRef(null);

    // Init audio sekali saat mount
    useEffect(() => {
        const audio = new Audio(PLAYLIST[0].src);
        audio.volume = volume;
        audio.loop = playInLoop;

        // auto next saat lagu selesai
        const handleEnded = () => {
            setIndex((i) => (i + 1) % PLAYLIST.length);
        };
        audio.addEventListener('ended', handleEnded);

        audioRef.current = audio;

        return () => {
            audio.removeEventListener('ended', handleEnded);
            audio.pause();
            audioRef.current = null;
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    // Ganti lagu saat index berubah
    useEffect(() => {
        if (!audioRef.current) return;
        audioRef.current.src = PLAYLIST[index].src;
        audioRef.current.load();
        if (isPlaying) {
            // play bisa gagal tanpa user gesture di beberapa browser
            audioRef.current.play().catch(() => setIsPlaying(false));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [index]);

    // Sync volume ke element
    useEffect(() => {
        if (audioRef.current) audioRef.current.volume = volume;
    }, [volume]);

    // Sync loop
    useEffect(() => {
        if (audioRef.current) audioRef.current.loop = playInLoop;
    }, [playInLoop]);

    // 4) Controls
    const playSound = () => {
        if (!audioRef.current) return;
        audioRef.current.play().then(() => setIsPlaying(true)).catch(() => setIsPlaying(false));
    };

    const pauseSound = () => {
        if (!audioRef.current) return;
        audioRef.current.pause();
        setIsPlaying(false);
    };

    const stopSound = () => {
        if (!audioRef.current) return;
        audioRef.current.pause();
        audioRef.current.currentTime = 0;
        setIsPlaying(false);
    };

    const nextSong = () => setIndex((i) => (i + 1) % PLAYLIST.length);
    const prevSong = () => setIndex((i) => (i - 1 + PLAYLIST.length) % PLAYLIST.length);

    return (
        <div className="fixed bottom-4 left-4 right-4 md:left-4 md:right-auto">
            <GlassComponent className="px-6 py-4 flex flex-col rounded-xl">
                <div className="flex justify-between items-center gap-6">
                    <div className="flex items-center justify-between">
                        <div className="font-bold text-xl uppercase">
                            {PLAYLIST[index].title}
                        </div>
                    </div>

                    {/* Controls */}
                    <div className="flex items-center gap-4 text-xl">
                        <button className="btn btn-secondary" onClick={prevSong} title="Previous">
                            <FontAwesomeIcon icon={faBackwardStep} />
                        </button>

                        {isPlaying ? (
                            <button className="btn btn-warning text-3xl" onClick={pauseSound} title="Pause">
                                <FontAwesomeIcon icon={faPause} />
                            </button>
                        ) : (
                            <button className="btn btn-primary text-3xl" onClick={playSound} title="Play">
                                <FontAwesomeIcon icon={faPlay} />
                            </button>
                        )}

                        <button className="btn btn-secondary" onClick={nextSong} title="Next">
                            <FontAwesomeIcon icon={faForwardStep} />
                        </button>
                    </div>
                </div>

                {/* Volume slider */}
                {/* <div className="flex items-center gap-3">
                    <div className="flex-1 w-full">
                        <ElasticSlider
                            leftIcon={<FontAwesomeIcon icon={faVolumeOff} className="opacity-70" />}
                            rightIcon={<FontAwesomeIcon icon={faVolumeHigh} className="opacity-70" />}
                            startingValue={0}
                            defaultValue={Math.round(volume * 100)}  // 0..100
                            maxValue={100}
                            isStepped
                            stepSize={1}
                            onChange={(val) => setVolume(Math.min(1, Math.max(0, (val ?? 0) / 100)))}
                        />
                    </div>
                </div> */}
            </GlassComponent>
        </div>
    );
};
