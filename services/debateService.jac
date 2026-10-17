import from os { getenv }

obj DebateMessage {
    has agent: str;
    has text: str;
}

obj DebateResult {
    has messages: list[DebateMessage];
    has vote: str;
}

sem DebateMessage.agent = "The speaker's persona name, without an article.";
sem DebateMessage.text = "A concise contribution to the decision debate.";

def accountant_take(decision: str) -> str by llm(temperature=0.4, max_tokens=600);
sem accountant_take = "Act as The Accountant. Give a concise, two-sentence financial take on the decision.";
sem accountant_take.decision = "The user's life decision to evaluate.";

def environmentalist_take(decision: str, accountant: str) -> str by llm(temperature=0.4, max_tokens=600);
sem environmentalist_take = "Act as The Environmentalist. Respond directly to The Accountant's point, focusing on sustainability and ethics. Keep it concise.";
sem environmentalist_take.decision = "The user's life decision.";
sem environmentalist_take.accountant = "The Accountant's financial point to respond to.";

def cynic_take(decision: str, accountant: str, environmentalist: str) -> str by llm(temperature=0.4, max_tokens=600);
sem cynic_take = "Act as The Cynic. Concisely criticize both prior perspectives and identify a practical risk.";
sem cynic_take.decision = "The user's life decision.";
sem cynic_take.accountant = "The Accountant's financial view.";
sem cynic_take.environmentalist = "The Environmentalist's response.";

def optimist_take(decision: str, accountant: str, environmentalist: str, cynic: str) -> str by llm(temperature=0.4, max_tokens=600);
sem optimist_take = "Act as The Optimist. Concisely summarize a realistic silver lining after considering all three previous points.";
sem optimist_take.decision = "The user's life decision.";
sem optimist_take.accountant = "The Accountant's financial take.";
sem optimist_take.environmentalist = "The Environmentalist's response.";
sem optimist_take.cynic = "The Cynic's criticism.";

def final_board_vote(decision: str, accountant: str, environmentalist: str, cynic: str, optimist: str) -> str by llm(temperature=0.3, max_tokens=600);
sem final_board_vote = "Return a concise final board recommendation with a vote tally out of four and practical recommendation. Be consistent with the discussion.";
sem final_board_vote.decision = "The decision under discussion.";
sem final_board_vote.accountant = "Accountant's take.";
sem final_board_vote.environmentalist = "Environmentalist's response.";
sem final_board_vote.cynic = "Cynic's critique.";
sem final_board_vote.optimist = "Optimist's silver lining.";

async def orchestrate_debate(decision: str) -> DebateResult {
    if not decision.strip() {
        raise ValueError("Decision cannot be empty.");
    }
    print("Debate request accepted; starting Groq-backed LLM chain.");
    print("Debate LLM stage: Accountant");
    accountant = accountant_take(decision);
    print("Debate LLM stage complete: Accountant");
    print("Debate LLM stage: Environmentalist");
    environmentalist = environmentalist_take(decision, accountant);
    print("Debate LLM stage complete: Environmentalist");
    print("Debate LLM stage: Cynic");
    cynic = cynic_take(decision, accountant, environmentalist);
    print("Debate LLM stage complete: Cynic");
    print("Debate LLM stage: Optimist");
    optimist = optimist_take(decision, accountant, environmentalist, cynic);
    print("Debate LLM stage complete: Optimist");
    print("Debate LLM stage: Final vote");
    vote = final_board_vote(decision, accountant, environmentalist, cynic, optimist);
    print("Debate request completed successfully.");
    return DebateResult(
        messages=[
            DebateMessage(agent="Accountant", text=accountant),
            DebateMessage(agent="Environmentalist", text=environmentalist),
            DebateMessage(agent="Cynic", text=cynic),
            DebateMessage(agent="Optimist", text=optimist)
        ],
        vote=vote
    );
}

async def:pub debate_api(decision: str) -> DebateResult {
    try {
        return await orchestrate_debate(decision);
    } except Exception as e {
        print("POST /api/debate failed:", type(e).__name__, str(e));
        raise;
    }
}
