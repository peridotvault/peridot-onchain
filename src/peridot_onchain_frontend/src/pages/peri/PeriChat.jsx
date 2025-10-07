import React, { useEffect, useLayoutEffect, useRef, useState } from "react";
import { EyeglassesIcon } from "../../assets/icons/MainIcons";

/* ---------------- utils sanitasi jawaban (JS only) ---------------- */
function stripXmlBlocks(s) {
    return s
        .replace(/<think[\s\S]*?<\/think>/gi, "")
        .replace(/<analysis[\s\S]*?<\/analysis>/gi, "");
}
function stripFencedBlocks(s) {
    return s.replace(/```[\s\S]*?```/g, "");
}
function unquote(s) {
    return s.replace(/^[\s"'`]+|[\s"'`]+$/g, "").trim();
}
function collapseWS(s) {
    return s.replace(/[ \t]+/g, " ").replace(/\n{3,}/g, "\n\n").trim();
}
function limitSentences(s, n) {
    const parts = s.split(/(?<=[.!?])\s+/).filter(Boolean);
    return parts.slice(0, n).join(" ");
}
function extractText(raw) {
    if (typeof raw === "string") return raw;
    return (
        (raw && (raw.response || raw.text || raw.message)) ||
        (raw && raw.data && (raw.data.response || raw.data.text)) ||
        ""
    );
}
function sanitizeReply(raw, opts) {
    const maxSentences = (opts && opts.maxSentences) || 3;
    let t = extractText(raw);
    t = stripXmlBlocks(t);
    t = stripFencedBlocks(t);
    t = unquote(t);
    t = collapseWS(t);
    if (maxSentences > 0) t = limitSentences(t, maxSentences);
    return t || "…";
}

/* ---------------- autosize hook (JS only) ---------------- */
function useAutosizeTextArea(textAreaRef, value) {
    useLayoutEffect(() => {
        const el = textAreaRef && textAreaRef.current;
        if (!el) return;
        el.style.height = "0px";
        el.style.height = el.scrollHeight + "px";
    }, [textAreaRef, value]);
}

export const PeriChat = () => {
    const [input, setInput] = useState("");
    const [msgs, setMsgs] = useState(() => {
        try {
            return JSON.parse(localStorage.getItem("peri_chat_msgs") || "[]");
        } catch {
            return [];
        }
    });
    const [loading, setLoading] = useState(false);

    const listRef = useRef(null);
    const inputRef = useRef(null);
    const abortRef = useRef(null);
    useAutosizeTextArea(inputRef, input);

    const questionLists = [
        { question: "What is PeridotVault?" },
        { question: "Tell me All PeridotVault Roadmap!" },
    ];

    const isEmpty = msgs.length === 0;

    async function json(res) {
        if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`);
        return res.json();
    }

    // Selalu return string yang sudah “bersih”
    async function chat(query) {
        if (abortRef.current) abortRef.current.abort();
        const ac = new AbortController();
        abortRef.current = ac;

        const raw = await json(
            await fetch("https://chatbot.peridotvault.com/api/v1/chat", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ query }),
                signal: ac.signal,
            })
        );
        return sanitizeReply(raw, { maxSentences: 3 });
    }

    useEffect(() => {
        localStorage.setItem("peri_chat_msgs", JSON.stringify(msgs));
    }, [msgs]);

    useLayoutEffect(() => {
        if (!listRef.current) return;
        listRef.current.scrollTo({ top: listRef.current.scrollHeight, behavior: "smooth" });
    }, [msgs.length, loading]);

    async function send(text) {
        const trimmed = (text || "").trim();
        if (!trimmed || loading) return;

        const userMsg = { id: crypto.randomUUID(), role: "user", text: trimmed };
        setMsgs((m) => [...m, userMsg]);
        setLoading(true);
        setInput("");

        try {
            const reply = await chat(trimmed);
            const aiMsg = { id: crypto.randomUUID(), role: "assistant", text: reply };
            setMsgs((m) => [...m, aiMsg]);
        } catch (e) {
            const aiMsg = {
                id: crypto.randomUUID(),
                role: "assistant",
                text: "Sorry, something went wrong. Please contact support.",
            };
            setMsgs((m) => [...m, aiMsg]);
            console.error(e);
        } finally {
            setLoading(false);
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
            {isEmpty ? (
                <div className="h-full w-full max-w-3xl mx-auto px-4 flex flex-col items-center justify-center gap-12 text-center">
                    <div className="flex flex-col gap-6 items-center">
                        <EyeglassesIcon className="w-28 h-28 opacity-80" />
                        <div className="flex flex-col items-center gap-2">
                            <h1 className="text-5xl font-bold max-md:text-3xl">How can I help you today?</h1>
                            <span className="text-text_disabled text-xl">Give Peri a task to work</span>
                        </div>
                    </div>

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
                <div className="h-full w-full mx-auto px-4 pt-6 pb-4 flex flex-col items-center gap-4">
                    <div
                        ref={listRef}
                        className="flex-1 min-h-0 w-full overflow-y-auto space-y-4 text-left items-center flex flex-col"
                        aria-live="polite"
                        aria-busy={loading ? "true" : "false"}
                    >
                        {msgs.map((m) => (
                            <div key={m.id} className={`w-full max-w-3xl flex ${m.role === "user" ? "justify-end" : "justify-start"}`}>
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
                                        <span className="h-2 w-2 bg-background_disabled rounded-full inline-block animate-bounce" />
                                        <span className="h-2 w-2 bg-background_disabled rounded-full inline-block animate-bounce" style={{ animationDelay: "120ms" }} />
                                        <span className="h-2 w-2 bg-background_disabled rounded-full inline-block animate-bounce" style={{ animationDelay: "240ms" }} />
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
