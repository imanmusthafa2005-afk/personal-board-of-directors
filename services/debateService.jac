import from http { HTTPMethod }

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

def accountant_take(decision: str) -> str by llm(temperature=0.4, max_tokens=120);
sem accountant_take = "Act as The Accountant. Give a concise, two-sentence financial take on the decision.";
sem accountant_take.decision = "The user's life decision to evaluate.";

def environmentalist_take(decision: str, accountant: str) -> str by llm(temperature=0.4, max_tokens=120);
sem environmentalist_take = "Act as The Environmentalist. Respond directly to The Accountant's point, focusing on sustainability and ethics. Keep it concise.";
sem environmentalist_take.decision = "The user's life decision.";
sem environmentalist_take.accountant = "The Accountant's financial point to respond to.";

def cynic_take(decision: str, accountant: str, environmentalist: str) -> str by llm(temperature=0.4, max_tokens=120);
sem cynic_take = "Act as The Cynic. Concisely criticize both prior perspectives and identify a practical risk.";
sem cynic_take.decision = "The user's life decision.";
sem cynic_take.accountant = "The Accountant's financial view.";
sem cynic_take.environmentalist = "The Environmentalist's response.";

def optimist_take(decision: str, accountant: str, environmentalist: str, cynic: str) -> str by llm(temperature=0.4, max_tokens=120);
sem optimist_take = "Act as The Optimist. Concisely summarize a realistic silver lining after considering all three previous points.";
sem optimist_take.decision = "The user's life decision.";
sem optimist_take.accountant = "The Accountant's financial take.";
sem optimist_take.environmentalist = "The Environmentalist's response.";
sem optimist_take.cynic = "The Cynic's criticism.";

def final_board_vote(decision: str, accountant: str, environmentalist: str, cynic: str, optimist: str) -> str by llm(temperature=0.3, max_tokens=100);
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
    accountant = await accountant_take(decision);
    environmentalist = await environmentalist_take(decision, accountant);
    cynic = await cynic_take(decision, accountant, environmentalist);
    optimist = await optimist_take(decision, accountant, environmentalist, cynic);
    vote = await final_board_vote(decision, accountant, environmentalist, cynic, optimist);
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

@restspec(method=HTTPMethod.POST, path="/api/debate")
async def:pub debate_api(decision: str) -> DebateResult {
    return await orchestrate_debate(decision);
}
