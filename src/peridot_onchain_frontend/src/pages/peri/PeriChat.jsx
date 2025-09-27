import React, { useEffect, useLayoutEffect, useRef, useState } from "react";
import { peridot_ai } from "declarations/peridot_ai/index.js";
import { EyeglassesIcon } from "../../assets/icons/MainIcons";

export const PeriChat = () => {
    const [input, setInput] = useState("");
    // const [msgs, setMsgs] = useState(() => {
    //     try { return JSON.parse(localStorage.getItem("peri_chat_msgs") || "[]"); } catch { return []; }
    // });
    const [msgs, setMsgs] = useState(() => []);
    const [loading, setLoading] = useState(false);
    const listRef = useRef(null);
    const mountedRef = useRef(true);
    const inputRef = useRef(null);
    useAutosizeTextArea(inputRef, input);

    const questionLists = [
        { question: "What is PeridotVault?" },
        { question: "Tell me All PeridotVault Roadmap!" },
    ];

    const isEmpty = msgs.length === 0;

    async function chatWithPeri(prompt) {
        const res = await peridot_ai.chat(prompt);
        return String(res ?? "");
    }

    function useAutosizeTextArea(textAreaRef, value) {
        useLayoutEffect(() => {
            const el = textAreaRef?.current;
            if (!el) return;
            el.style.height = "0px";                   // reset dulu
            el.style.height = el.scrollHeight + "px";  // set ke konten
        }, [textAreaRef, value]);
    }

    useEffect(() => {
        localStorage.setItem("peri_chat_msgs", JSON.stringify(msgs));
    }, [msgs]);

    useEffect(() => {
        mountedRef.current = true;
        return () => { mountedRef.current = false; };
    }, []);

    useLayoutEffect(() => {
        if (!listRef.current) return;
        listRef.current.scrollTo({ top: listRef.current.scrollHeight, behavior: "smooth" });
    }, [msgs.length, loading]);

    async function send(text) {
        const trimmed = text.trim();
        if (!trimmed || loading) return;
        setMsgs((m) => [...m, { id: crypto.randomUUID(), role: "user", text: trimmed, ts: Date.now() }]);
        setInput("");
        setLoading(true);
        try {
            const reply = await chatWithPeri(trimmed);
            if (!mountedRef.current) return;
            setMsgs((m) => [...m, { id: crypto.randomUUID(), role: "assistant", text: reply || "…", ts: Date.now() }]);
        } catch (e) {
            if (!mountedRef.current) return;
            setMsgs((m) => [...m, { id: crypto.randomUUID(), role: "assistant", text: "Maaf, terjadi kesalahan.", ts: Date.now() }]);
            console.error(e);
        } finally {
            if (mountedRef.current) setLoading(false);
        }
    }

    function onSubmit(e) {
        e.preventDefault();
        if (!loading) send(input);
    }
    function onKeyDown(e) {
        if (e.key === "Enter" && !e.shiftKey && !loading) {
            e.preventDefault();
            send(input);
        }
    }

    return (
        <section className="w-full h-screen pt-24">
            {/* === WELCOME MODE: semua di tengah === */}
            {isEmpty ? (
                <div className="h-full w-full max-w-3xl mx-auto px-4 flex flex-col items-center justify-center gap-12 text-center">
                    <div className="flex flex-col gap-6 items-center">
                        <EyeglassesIcon className="w-28 h-28 opacity-80" />
                        <div className="flex flex-col items-center gap-2">
                            <h1 className="text-5xl font-bold max-md:text-3xl">How can I help you today?</h1>
                            <span className="text-text_disabled text-xl">Give Peri a task to work</span>
                        </div>
                    </div>

                    {/* Input di TENGAH (bukan bawah) */}
                    <form onSubmit={onSubmit} className="w-full">
                        <div className="bg-background_primary border border-white/10 rounded-lg p-2">
                            <textarea
                                ref={inputRef}
                                value={input}
                                onChange={(e) => setInput(e.target.value)}
                                onKeyDown={onKeyDown}
                                placeholder={loading ? "Thinking..." : "Give Peri a task..."}
                                rows={1}
                                className="w-full resize-none bg-transparent outline-none p-2 disabled:opacity-50"
                                disabled={loading}
                            />
                            <div className="flex justify-end px-2 pb-1 text-xs text-text_disabled">
                                <span>Enter to send • Shift+Enter for newline</span>
                            </div>
                        </div>
                    </form>

                    <ol className="w-full border border-white/10 rounded-lg divide-y divide-white/10 overflow-hidden text-left">
                        {questionLists.map((item, idx) => (
                            <li key={idx}>
                                <button
                                    className="py-4 px-4 w-full text-start hover:bg-white/5 transition"
                                    onClick={() => send(item.question)}
                                >
                                    {item.question}
                                </button>
                            </li>
                        ))}
                    </ol>
                </div>
            ) : (
                /* === CHAT MODE: list scroll + input di bawah === */
                <div className="h-full w-full mx-auto px-4 pt-6 pb-4 flex flex-col items-center gap-4">
                    <div
                        ref={listRef}
                        className="flex-1 min-h-0 w-full overflow-y-auto space-y-4 text-left items-center flex flex-col"
                        aria-live="polite"
                        aria-busy={loading ? "true" : "false"}
                    >
                        {msgs.map((m) => (
                            <div key={m.id} className={`w-full max-w-3xl  flex ${m.role === "user" ? "justify-end" : "justify-start"}`}>
                                <div
                                    className={`max-w-[80%] rounded-xl px-4 py-3 leading-relaxed border border-white/10 whitespace-pre-wrap break-words ${m.role === "user" ? "bg-white/10 text-white" : "bg-background_primary/80 text-white/90"
                                        }`}
                                >
                                    {m.text}
                                </div>
                            </div>
                        ))}

                        {loading && (
                            <div className="w-full max-w-3xl flex justify-start">
                                <div className="max-w-[80%]">
                                    <div className="text-[10px] tracking-wider text-text_disabled/70 mb-1">Peri</div>
                                    <div className="rounded-xl border border-white/10 px-4 py-3 bg-background_primary/80 inline-flex items-center gap-1">
                                        <span className="h-2 w-2 rounded-full inline-block animate-bounce" />
                                        <span className="h-2 w-2 rounded-full inline-block animate-bounce" style={{ animationDelay: "120ms" }} />
                                        <span className="h-2 w-2 rounded-full inline-block animate-bounce" style={{ animationDelay: "240ms" }} />
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>

                    <form onSubmit={onSubmit} className="sticky bottom-0 w-full max-w-3xl">
                        <div className="bg-background_primary border border-white/10 rounded-lg p-2">
                            <textarea
                                ref={inputRef}
                                value={input}
                                onChange={(e) => setInput(e.target.value)}
                                onKeyDown={onKeyDown}
                                placeholder={loading ? "Thinking..." : "Give Peri a task..."}
                                rows={1}
                                className="w-full resize-none bg-transparent outline-none p-2 disabled:opacity-50 max-h-[40vh]"
                                disabled={loading}
                            />
                            <div className="flex justify-end px-2 pb-1 text-xs text-text_disabled">
                                <span>Enter to send • Shift+Enter for newline</span>
                            </div>
                        </div>
                    </form>
                </div>
            )}
        </section>
    );
};
