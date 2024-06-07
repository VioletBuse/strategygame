use serde::{Deserialize, Serialize};
use serde_json;
use worker::*;

#[derive(Debug, Serialize, Deserialize)]
pub enum GameMessage {
    NoOp,
}

#[derive(Debug, Serialize, Deserialize)]
pub enum GameResponse {
    NoOpResponse,
}

#[durable_object]
pub struct Game {
    state: State,
    env: Env,
}

#[durable_object]
impl DurableObject for Game {
    fn new(state: State, env: Env) -> Self {
        Self { state, env }
    }
    async fn fetch(&mut self, req: Request) -> Result<Response> {
        let mut req = req.clone()?;
        let text = req.text().await?;
        let message: GameMessage = serde_json::from_str(text.as_str())?;

        let res: GameResponse = match message {
            GameMessage::NoOp => GameResponse::NoOpResponse,
        };

        Response::from_json(&res)
    }
}

pub async fn query(stub: Stub, message: GameMessage) -> Result<GameResponse> {
    let serialized_message = serde_json::to_string(&message)?;
    let message_jsvalue = wasm_bindgen::JsValue::from_str(serialized_message.as_str());
    let init = RequestInit {
        method: Method::Get,
        body: Some(message_jsvalue),
        headers: Headers::new(),
        cf: CfProperties::default(),
        redirect: RequestRedirect::Follow,
    };
    let request = Request::new_with_init("https://game.internal/", &init)?;

    let mut response = stub.fetch_with_request(request).await?;
    let text = response.text().await?;
    let deserialized: GameResponse = serde_json::from_str(text.as_str())?;

    Ok(deserialized)
}
