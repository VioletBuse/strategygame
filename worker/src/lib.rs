use worker::*;

#[event(fetch)]
async fn fetch(req: Request, env: Env, _ctx: Context) -> Result<Response> {
    Router::new()
        .get_async("/hello", |_req, _ctx| async move {
            Response::error("Not found lol", 404)
        })
        .run(req, env)
        .await
}
