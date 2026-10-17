obj DebateMessage {
    has agent: str;
    has text: str;
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

async def:pub orchestrate_debate(decision: str) -> list[DebateMessage] {
    if not decision.strip() {
        raise ValueError("Decision cannot be empty.");
    }
    accountant = await accountant_take(decision);
    environmentalist = await environmentalist_take(decision, accountant);
    cynic = await cynic_take(decision, accountant, environmentalist);
    optimist = await optimist_take(decision, accountant, environmentalist, cynic);
    return [
        DebateMessage(agent="Accountant", text=accountant),
        DebateMessage(agent="Environmentalist", text=environmentalist),
        DebateMessage(agent="Cynic", text=cynic),
        DebateMessage(agent="Optimist", text=optimist)
    ];
}
