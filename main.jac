import from .services.debateService { orchestrate_debate }
import from .frontend { app as ClientApp }

def:pub app() -> JsxElement {
    return <ClientApp />;
}
