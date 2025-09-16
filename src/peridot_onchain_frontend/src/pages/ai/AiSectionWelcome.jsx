import React, { useState, useRef, useEffect } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faHandPointDown } from '@fortawesome/free-solid-svg-icons'
import { peridot_ai } from "declarations/peridot_ai/index.js"

export const AiSectionWelcome = () => {
    const [input, setInput] = useState("");
    const [msgs, setMsgs] = useState([]);
    const [loading, setLoading] = useState(false);
    const listRef = useRef(null);

    async function chatWithPeri(prompt) {
        const res = await peridot_ai.chat(prompt);
        return String(res ?? "");
    }

    useEffect(() => {
        if (listRef.current) {
            listRef.current.scrollTo({ top: listRef.current.scrollHeight, behavior: "smooth" });
        }
    }, [msgs.length, loading]);

    async function send(text) {
        if (!text.trim() || loading) return;
        const userMsg = { id: crypto.randomUUID(), role: "user", text };
        setMsgs((m) => [...m, userMsg]);
        setLoading(true);
        setInput("");

        try {
            const reply = await chatWithPeri(text);
            const aiMsg = { id: crypto.randomUUID(), role: "assistant", text: reply || "…" };
            setMsgs((m) => [...m, aiMsg]);
        } catch (e) {
            const aiMsg = { id: crypto.randomUUID(), role: "assistant", text: "Maaf, terjadi kesalahan." };
            setMsgs((m) => [...m, aiMsg]);
            console.error(e);
        } finally {
            setLoading(false);
        }
    }

    async function onKeyDown(e) {
        if (e.key === "Enter" && !loading) {
            e.preventDefault();
            await send(input);
        }
    }

    return (
        <section className="w-full h-screen p-4 flex items-center justify-evenly max-md:flex-col duration-300 relative bg-background_secondary">
            <div>
                <div>
                    <div className=''>
                        <p className='text-4xl font-medium'>Meet Our Intelligent AI</p>
                    </div>
                    <div>
                        <p className='text-8xl text-accent_primary font-extrabold'>Peri</p>
                    </div>
                </div>
            </div>
            <div className='rounded-2xl border border-white/10 w-1/2 max-md:w-full max-w-[768px] max-h-[768px] h-2/3 max-md:h-1/2 p-8 flex flex-col gap-8'>
                {/* Header */}
                <div className="flex flex-col items-center gap-4 text-center">
                    <h1 className="text-4xl font-bold max-md:text-3xl">How can I help you today?</h1>
                    <span className="text-text_disabled text-xl">Give Peri a task to work</span>
                </div>

                {/* Scrollable Message List */}
                <div ref={listRef} className="flex-1 space-y-4 overflow-y-auto text-left">
                    {msgs.map((m) => (
                        <div key={m.id} className={`w-full flex ${m.role === "user" ? "justify-end" : "justify-start"}`}>
                            <div className="max-w-[80%]">
                                <div className="text-[10px] uppercase tracking-wider text-text_disabled/70 mb-1">
                                    {m.role === "user" ? "You" : "Peri"}
                                </div>
                                <div
                                    className={`rounded-xl border border-white/10 px-4 py-3 text-sm leading-relaxed ${m.role === "user" ? "bg-white/10" : "bg-background_primary/80"
                                        }`}
                                >
                                    {m.text}
                                </div>
                            </div>
                        </div>
                    ))}

                    {loading && (
                        <div className="w-full flex justify-start">
                            <div className="max-w-[80%]">
                                <div className="text-[10px] uppercase tracking-wider text-text_disabled/70 mb-1">Peri</div>
                                <div className="rounded-xl border border-white/10 px-4 py-3 bg-background_primary/80 inline-flex items-center gap-1">
                                    <span className="h-2 w-2 rounded-full bg-white/60 inline-block animate-bounce" style={{ animationDelay: "0ms" }} />
                                    <span className="h-2 w-2 rounded-full bg-white/60 inline-block animate-bounce" style={{ animationDelay: "120ms" }} />
                                    <span className="h-2 w-2 rounded-full bg-white/60 inline-block animate-bounce" style={{ animationDelay: "240ms" }} />
                                </div>
                            </div>
                        </div>
                    )}
                </div>

                {/* Input */}
                <input
                    type="text"
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    onKeyDown={onKeyDown}
                    placeholder={loading ? "Thinking..." : "Give Peri a task..."}
                    className="bg-background_primary border border-white/10 rounded-lg py-2 px-6 w-full disabled:opacity-50"
                    disabled={loading} // Add this line
                />
            </div>
            <div className="absolute z-0 bottom-8 left-0 flex flex-col items-center gap-2 w-full justify-center animate-bounce">
                <span>Explore More</span>
                <FontAwesomeIcon icon={faHandPointDown} />
            </div>
        </section>
    )
}
