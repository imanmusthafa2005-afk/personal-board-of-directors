import from services.debateService { orchestrate_debate, debate_api }
import from .frontend { app as ClientApp }

def:pub app() -> JsxElement {
    return <ClientApp />;
}
