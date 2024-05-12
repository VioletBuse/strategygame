use serde::{Deserialize, Serialize};
use serde_json;
use worker::*;

#[derive(Debug, Serialize, Deserialize)]
pub enum GameMessage {
    AddPlayer,
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

        match message {
            GameMessage::AddPlayer => Response::empty(),
        }
    }
}
