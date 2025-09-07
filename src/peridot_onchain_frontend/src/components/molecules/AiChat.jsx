import React, { useEffect, useRef, useState } from "react";
import { peridot_ai } from "declarations/peridot_ai/index.js"

export const AiChat = () => {
    const [mode, setMode] = useState("welcome"); // "welcome" | "chat"
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
        setMode("chat");
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

    function onKeyDown(e) {
        if (e.key === "Enter") {
            e.preventDefault();
            send(input);
        }
    }

    if (mode === "welcome") {
        return (
            <div className="h-full z-10 flex items-center justify-center w-full pointer-events-none p-8 text-center flex-col gap-16">
                <div className="flex flex-col items-center gap-4">
                    <h1 className="text-4xl font-bold max-md:text-3xl">How can I help you today?</h1>
                    <span className="text-text_disabled text-xl">Give Peri a task to work</span>
                </div>

                <input
                    type="text"
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    onKeyDown={onKeyDown}
                    placeholder="Give Peri a task..."
                    className="bg-background_primary border border-white/10 rounded-lg py-2 px-6 w-full max-w-[400px] pointer-events-auto"
                />
            </div>
        );
    }

    return (
        <div className="absolute w-full h-full flex justify-center">

            <div className=" w-[600px] h-full inset-0 flex flex-col px-8 py-32">
                <div ref={listRef} className="flex-1 overflow-y-auto  space-y-4">
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

                <div className="border-t border-white/10 p-3">
                    <div className="flex items-center gap-2">
                        <input
                            type="text"
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            onKeyDown={onKeyDown}
                            placeholder="Type a message…"
                            className="flex-1 bg-background_primary border border-white/10 rounded-lg px-4 py-2 outline-none focus:border-white/20 transition-colors"
                        />
                        <button
                            onClick={() => send(input)}
                            disabled={loading || !input.trim()}
                            className="px-4 py-2 rounded-lg border border-white/10 bg-white/5 hover:bg-white/10 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                        >
                            Send
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};
