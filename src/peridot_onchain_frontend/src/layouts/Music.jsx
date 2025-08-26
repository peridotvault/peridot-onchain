import React, { useEffect, useRef, useState } from 'react';
import GlassComponent from '../components/atoms/GlassComponent';
import ElasticSlider from '../components/atoms/ElasticSlider';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
    faPlay, faPause,
    faForwardStep, faBackwardStep,
    faVolumeOff, faVolumeHigh,
} from '@fortawesome/free-solid-svg-icons';

export const Music = () => {
    // 1) Playlist: tinggal tambah/kurangi di sini
    const PLAYLIST = [
        { title: 'Vault Theme', author: "PeridotVault", src: '/assets/music/vault.mp3', imgUrl: "./logo/logo-bg.png" },
        { title: 'Arena', author: "PeridotVault", src: '/assets/music/arena.mp3', imgUrl: "./logo/logo-bg.png" },
        { title: 'Nebula', author: "PeridotVault", src: '/assets/music/nebula.mp3', imgUrl: "./logo/logo-bg.png" },
    ];

    // 2) States
    const [index, setIndex] = useState(0);
    const [isPlaying, setIsPlaying] = useState(false);
    const [volume, setVolume] = useState(0.7); // 0.0 - 1.0
    const [volOpen, setVolOpen] = useState(false);

    // 3) Single audio element (persist)
    const audioRef = useRef(null);

    // Init audio sekali saat mount
    useEffect(() => {
        const audio = new Audio(PLAYLIST[0].src);
        audio.volume = volume;

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

    const nextSong = () => setIndex((i) => (i + 1) % PLAYLIST.length);
    const prevSong = () => setIndex((i) => (i - 1 + PLAYLIST.length) % PLAYLIST.length);

    return (
        <div className="fixed bottom-4 left-4 group z-50 max-md:hidden">
            <GlassComponent className="pl-4 pr-8 py-2 flex flex-col rounded-full">
                <div className="flex justify-between items-center gap-6">
                    {/* music detail  */}
                    <div className="flex items-center gap-8 border border-white/10 bg-black/20 p-2 pr-6 rounded-full duration-100">
                        <div className="flex items-center">
                            <div className="bg-white/10 h-10 w-10 rounded-full overflow-hidden border border-white/5">
                                <img src={PLAYLIST[index].imgUrl} alt="" className='w-full h-full object-cover' /></div>
                            <div className="leading-3 max-w-0 group-hover:max-w-[30rem] overflow-hidden duration-300 ">
                                <span className="pl-2 text-base truncate">{PLAYLIST[index].title}</span>
                                <br />
                                <span className='pl-2 text-xs text-white/60 truncate'>{PLAYLIST[index].author}</span>
                            </div>
                        </div>

                        {/* Controls */}
                        <div className="flex items-center gap-8 text-2xl ">
                            <button className="btn btn-secondary" onClick={prevSong} title="Previous">
                                <FontAwesomeIcon icon={faBackwardStep} />
                            </button>

                            {isPlaying ? (
                                <button className="btn btn-warning" onClick={pauseSound} title="Pause">
                                    <FontAwesomeIcon icon={faPause} />
                                </button>
                            ) : (
                                <button className="btn btn-primary" onClick={playSound} title="Play">
                                    <FontAwesomeIcon icon={faPlay} />
                                </button>
                            )}

                            <button className="btn btn-secondary" onClick={nextSong} title="Next">
                                <FontAwesomeIcon icon={faForwardStep} />
                            </button>
                        </div>


                    </div>

                    {/* Volume slider */}
                    <div className="relative" onMouseEnter={() => setVolOpen(true)} onMouseLeave={() => setVolOpen(false)}>
                        <button onClick={() => setVolOpen(v => !v)}
                            title="Volume"
                            aria-expanded={volOpen}>
                            <FontAwesomeIcon icon={faVolumeHigh} className="opacity-70" />
                        </button>
                        <div className={`absolute left-12 top-1/2 -translate-y-1/2 transition-all duration-300
                   ${volOpen ? "opacity-100 -translate-x-10 bg-white/10 rounded-full px-4" : "opacity-0 -translate-x-2 pointer-events-none "}`}>
                            <div className="w-48">
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
                        </div>
                    </div>



                </div>


            </GlassComponent>
        </div>
    );
};
