import ".styles.global.css";
import from "@hugeicons/react" { HugeiconsIcon }
import from "@hugeicons/core-free-icons" { SparklesIcon, Alert01Icon, ArrowUpRight01Icon, DollarCircleIcon, GlobeIcon, Message01Icon }
import from .components.ui.button { Button }
import from .components.ui.card { Card, CardContent }
import from .components.ui.textarea { Textarea }
import from .components.ui.avatar { Avatar, AvatarFallback }
sv import from .services.debateService { DebateResult, debate_api }

def:pub app() -> JsxElement {
    has decisionInput: str = "";
    has isDebating: bool = False;
    has messages: list[dict] = [];
    has debateComplete: bool = False;
    has finalVote: str = "";
    has bottomRef: Ref[HTMLDivElement] = Ref(None);
    has errorMessage: str = "";

    can with [messages] entry {
        if bottomRef.current {
            bottomRef.current.scrollIntoView({"behavior": "smooth", "block": "end"});
        }
    }

    def handle_decision_change(e: InputEvent) {
        decisionInput = e.target.value;
    }

    async def handle_submit(e: MouseEvent) {
        e.preventDefault();
        cleaned = decisionInput.strip();
        if cleaned and not isDebating {
            isDebating = True;
            errorMessage = "";
            decisionInput = "";
            user_messages: list[dict[str, str]] = [{"agent": "You", "text": cleaned}];
            messages = user_messages;
            debateComplete = False;
            finalVote = "";
            try {
                response_result = await debate_api(cleaned);
                response_messages = response_result.messages;
                visible_messages: list[dict[str, str]] = user_messages;
                for reply in response_messages {
                    await new(Promise, lambda (resolve: any, reject: any) {
                        setTimeout(lambda { resolve.call(None, None); }, 2000);
                    });
                    reply_item: dict[str, str] = {"agent": reply.agent, "text": reply.text};
                    visible_messages = visible_messages + [reply_item];
                    messages = visible_messages;
                }
                if len(response_messages) > 0 {
                    finalVote = response_result.vote;
                } else {
                    finalVote = "The Board could not reach a recommendation.";
                }
                debateComplete = True;
            } except Exception {
                messages = [];
                errorMessage = "The board is currently out of office. Please try again.";
            }
            isDebating = False;
        }
    }

    def start_new_decision(e: MouseEvent) {
        decisionInput = "";
        messages = [];
        errorMessage = "";
        finalVote = "";
        debateComplete = False;
        isDebating = False;
    }

    return <main className="min-h-screen bg-muted/40 px-4 py-10 text-foreground sm:px-6 lg:py-14">
        <div className="mx-auto flex w-full max-w-5xl flex-col gap-10 animate-in fade-in slide-in-from-bottom-2 duration-500">
            <header className="flex flex-col items-center gap-5 text-center">
                <div className="flex size-12 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm">
                    <HugeiconsIcon icon={SparklesIcon} strokeWidth={2} className="size-6" />
                </div>
                <div className="flex max-w-2xl flex-col gap-3">
                    <p className="text-xs font-semibold uppercase tracking-[0.2em] text-primary">A clearer way forward</p>
                    <h1 className="text-balance text-4xl font-semibold leading-[1.1] tracking-tight md:text-5xl">Personal Board of Directors</h1>
                    <p className="text-base leading-relaxed text-muted-foreground">Submit a life decision and let your AI Board of Directors debate it.</p>
                </div>
            </header>

            <Card className="border-border/80 bg-card shadow-md">
                <CardContent className="flex flex-col gap-4 p-5 sm:p-7">
                    <div className="flex flex-col gap-1">
                        <label htmlFor="decision" className="text-sm font-semibold">What’s on your mind?</label>
                        <p className="text-sm text-muted-foreground">Give your board the context they need to weigh in.</p>
                    </div>
                    <textarea id="decision" value={decisionInput} onInput={handle_decision_change} disabled={isDebating} placeholder="Should I buy a used Honda or lease a new EV?" className="min-h-32 w-full resize-y rounded-xl border border-input bg-background px-3 py-3 text-base leading-relaxed outline-none focus-visible:ring-2 focus-visible:ring-ring/50" />
                    {if errorMessage {
                        <p role="alert" className="text-sm text-destructive">{errorMessage}</p>
                    }}
                    <div className="flex flex-col-reverse items-stretch justify-between gap-3 sm:flex-row sm:items-center">
                        <span className="text-xs text-muted-foreground">Your decision stays yours. Get a fresh perspective.</span>
                        <Button onClick={handle_submit} disabled={not decisionInput.strip() or isDebating} className="h-11 gap-2 rounded-xl px-5 shadow-sm">
                            <HugeiconsIcon icon={Message01Icon} strokeWidth={2} className="size-4" />
                            Submit to Board
                        </Button>
                    </div>
                </CardContent>
            </Card>

            <section className="flex flex-col gap-5" aria-labelledby="members-title">
                <div className="flex flex-wrap items-end justify-between gap-2">
                    <div className="flex flex-col gap-1">
                        <h2 id="members-title" className="text-2xl font-semibold tracking-tight">Meet your board</h2>
                        <p className="text-sm text-muted-foreground">Four distinct perspectives, one more considered decision.</p>
                    </div>
                    <span className="rounded-full border bg-card px-3 py-1 text-xs font-medium text-muted-foreground">4 perspectives</span>
                </div>
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <Card className="overflow-hidden border-border/80 bg-card shadow-sm transition-shadow hover:shadow-md">
                        <div className="h-1 bg-gradient-to-r from-slate-700 to-rose-500" />
                        <CardContent className="flex h-full flex-col gap-4 p-5">
                            <div className="flex size-10 items-center justify-center rounded-xl bg-slate-900 text-rose-300"><HugeiconsIcon icon={Alert01Icon} strokeWidth={2} className="size-5" /></div>
                            <div className="flex flex-col gap-1"><h3 className="font-semibold">The Cynic</h3><p className="text-sm leading-relaxed text-muted-foreground">Finds flaws, hidden risks, and the questions no one else is asking.</p></div>
                            <span className="mt-auto w-fit rounded-full bg-rose-500/10 px-2.5 py-1 text-xs font-medium text-rose-700">Risk &amp; reality</span>
                        </CardContent>
                    </Card>
                    <Card className="overflow-hidden border-border/80 bg-card shadow-sm transition-shadow hover:shadow-md">
                        <div className="h-1 bg-gradient-to-r from-yellow-400 to-orange-500" />
                        <CardContent className="flex h-full flex-col gap-4 p-5">
                            <div className="flex size-10 items-center justify-center rounded-xl bg-yellow-400/15 text-orange-600"><HugeiconsIcon icon={ArrowUpRight01Icon} strokeWidth={2} className="size-5" /></div>
                            <div className="flex flex-col gap-1"><h3 className="font-semibold">The Optimist</h3><p className="text-sm leading-relaxed text-muted-foreground">Sees the upside, new possibilities, and where this could take you.</p></div>
                            <span className="mt-auto w-fit rounded-full bg-orange-500/10 px-2.5 py-1 text-xs font-medium text-orange-700">Opportunity</span>
                        </CardContent>
                    </Card>
                    <Card className="overflow-hidden border-border/80 bg-card shadow-sm transition-shadow hover:shadow-md">
                        <div className="h-1 bg-gradient-to-r from-blue-500 to-emerald-500" />
                        <CardContent className="flex h-full flex-col gap-4 p-5">
                            <div className="flex size-10 items-center justify-center rounded-xl bg-blue-500/10 text-blue-700"><HugeiconsIcon icon={DollarCircleIcon} strokeWidth={2} className="size-5" /></div>
                            <div className="flex flex-col gap-1"><h3 className="font-semibold">The Accountant</h3><p className="text-sm leading-relaxed text-muted-foreground">Runs the numbers, weighs the trade-offs, and tracks long-term ROI.</p></div>
                            <span className="mt-auto w-fit rounded-full bg-blue-500/10 px-2.5 py-1 text-xs font-medium text-blue-700">Numbers &amp; ROI</span>
                        </CardContent>
                    </Card>
                    <Card className="overflow-hidden border-border/80 bg-card shadow-sm transition-shadow hover:shadow-md">
                        <div className="h-1 bg-gradient-to-r from-emerald-700 to-green-400" />
                        <CardContent className="flex h-full flex-col gap-4 p-5">
                            <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-700"><HugeiconsIcon icon={GlobeIcon} strokeWidth={2} className="size-5" /></div>
                            <div className="flex flex-col gap-1"><h3 className="font-semibold">The Environmentalist</h3><p className="text-sm leading-relaxed text-muted-foreground">Considers sustainability, wider impact, and the ethical choice.</p></div>
                            <span className="mt-auto w-fit rounded-full bg-emerald-500/10 px-2.5 py-1 text-xs font-medium text-emerald-700">Impact &amp; ethics</span>
                        </CardContent>
                    </Card>
                </div>
            </section>

            <section className="flex flex-col gap-4" aria-labelledby="debate-title">
                <div className="flex flex-col gap-1">
                    <div className="flex items-center gap-2"><span className="relative flex size-2"><span className="absolute inline-flex size-full animate-ping rounded-full bg-primary/50" /><span className="relative inline-flex size-2 rounded-full bg-primary" /></span><h2 id="debate-title" className="text-2xl font-semibold tracking-tight">Live Debate Chat</h2></div>
                    <p className="text-sm text-muted-foreground">{ "The Board is convening..." if isDebating else "Your submitted decisions appear here." }</p>
                </div>
                <div className="flex max-h-[500px] min-h-52 flex-col gap-4 overflow-y-auto rounded-2xl border border-border bg-card p-5 shadow-sm sm:p-7">
                    {if isDebating {
                        <div className="flex w-full items-start gap-3 animate-in fade-in slide-in-from-bottom-2 duration-300">
                            <Avatar className="size-9 border border-primary/15 bg-primary/10 text-primary"><AvatarFallback className="bg-primary/10 text-xs font-semibold text-primary">BD</AvatarFallback></Avatar>
                            <div className="flex items-center gap-3 rounded-2xl rounded-tl-md border border-border bg-muted/60 px-4 py-3 text-sm text-muted-foreground shadow-sm">
                                <span className="font-semibold text-foreground">The Board</span>
                                <span className="flex items-center gap-1" aria-label="The Board is thinking">
                                    <span className="size-1.5 animate-bounce rounded-full bg-primary [animation-delay:-0.3s]" />
                                    <span className="size-1.5 animate-bounce rounded-full bg-primary [animation-delay:-0.15s]" />
                                    <span className="size-1.5 animate-bounce rounded-full bg-primary" />
                                </span>
                            </div>
                        </div>
                    }}
                    {if len(messages) == 0 and not isDebating {
                        <div className="flex min-h-40 flex-col items-center justify-center gap-3 text-center">
                            <div className="flex size-12 items-center justify-center rounded-2xl bg-muted text-muted-foreground"><HugeiconsIcon icon={Message01Icon} strokeWidth={1.8} className="size-5" /></div>
                            <p className="font-medium">Your debate starts here</p>
                            <p className="max-w-sm text-sm leading-relaxed text-muted-foreground">Submit a decision above to bring your board’s perspectives together.</p>
                        </div>
                        skip;
                    }}
                    {for (i, text) in enumerate(messages) {
                        if text["agent"] == "Accountant" {
                            <div key={str(i)} className="flex w-full items-start gap-3 animate-in fade-in slide-in-from-bottom-2 duration-300">
                                <Avatar className="size-9 border border-blue-200 bg-blue-100 text-blue-800"><AvatarFallback className="bg-blue-100 text-xs font-semibold text-blue-800">AC</AvatarFallback></Avatar>
                                <div className="max-w-[90%] rounded-2xl rounded-tl-md border border-blue-200 bg-blue-50 px-4 py-3 text-sm leading-relaxed text-blue-950 shadow-sm sm:max-w-[75%]">
                                    <p className="mb-1 text-xs font-semibold text-blue-700">The Accountant</p>
                                    <p className="whitespace-pre-wrap">{text["text"]}</p>
                                </div>
                            </div>
                        }
                        elif text["agent"] == "Optimist" {
                            <div key={str(i)} className="flex w-full items-start gap-3 animate-in fade-in slide-in-from-bottom-2 duration-300">
                                <Avatar className="size-9 border border-amber-200 bg-amber-100 text-amber-800"><AvatarFallback className="bg-amber-100 text-xs font-semibold text-amber-800">OP</AvatarFallback></Avatar>
                                <div className="max-w-[90%] rounded-2xl rounded-tl-md border border-amber-200 bg-amber-50 px-4 py-3 text-sm leading-relaxed text-amber-950 shadow-sm sm:max-w-[75%]">
                                    <p className="mb-1 text-xs font-semibold text-amber-800">The Optimist</p>
                                    <p className="whitespace-pre-wrap">{text["text"]}</p>
                                </div>
                            </div>
                        }
                        elif text["agent"] == "Cynic" {
                            <div key={str(i)} className="flex w-full items-start gap-3 animate-in fade-in slide-in-from-bottom-2 duration-300">
                                <Avatar className="size-9 border border-rose-200 bg-slate-800 text-rose-100"><AvatarFallback className="bg-slate-800 text-xs font-semibold text-rose-100">CY</AvatarFallback></Avatar>
                                <div className="max-w-[90%] rounded-2xl rounded-tl-md border border-rose-200 bg-rose-50 px-4 py-3 text-sm leading-relaxed text-rose-950 shadow-sm sm:max-w-[75%]">
                                    <p className="mb-1 text-xs font-semibold text-rose-700">The Cynic</p>
                                    <p className="whitespace-pre-wrap">{text["text"]}</p>
                                </div>
                            </div>
                        }
                        else {
                            <div key={str(i)} className="flex w-full justify-end animate-in fade-in slide-in-from-bottom-2 duration-300">
                                <div className="max-w-[90%] rounded-2xl rounded-br-md bg-primary px-4 py-3 text-sm leading-relaxed text-primary-foreground shadow-sm sm:max-w-[75%]">
                                    <p className="mb-1 text-xs font-semibold text-primary-foreground/75">{text["agent"]}</p>
                                    <p className="whitespace-pre-wrap">{text["text"]}</p>
                                </div>
                            </div>
                        }
                    }}
                    {if debateComplete {
                        <div className="mt-3 flex flex-col gap-4 rounded-2xl border-2 border-primary/30 bg-primary/10 p-5 shadow-md animate-in fade-in slide-in-from-bottom-2 duration-300 sm:p-6">
                            <div>
                                <p className="text-xs font-semibold uppercase tracking-wider text-primary">Final Board Vote</p>
                                <p className="mt-2 text-xl font-bold leading-snug tracking-tight text-foreground">{finalVote}</p>
                            </div>
                            <Button onClick={start_new_decision} variant="outline" className="w-fit">New Decision</Button>
                        </div>
                    }}
                    <div ref={bottomRef} aria-hidden="true" className="h-px w-full shrink-0" />
                </div>
            </section>
            <footer className="border-t pt-5 text-center text-xs text-muted-foreground">Thoughtful decisions start with better questions.</footer>
        </div>
    </main>;
}
