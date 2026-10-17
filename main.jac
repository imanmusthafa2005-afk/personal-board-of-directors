import from services.debateService { DebateMessage, DebateResult, orchestrate_debate, debate_api }
import from .frontend { app as ClientApp }

def:pub app() -> JsxElement {
    return <ClientApp />;
}
