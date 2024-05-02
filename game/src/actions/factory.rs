use crate::actions;
use crate::actions::handlers;

type Handler = Box<dyn actions::ActionHandler>;

pub fn action_handler_factory(
    handler_ids: Vec<String>,
) -> Result<actions::ActionsExecutor, actions::PlayerActionHandlingError> {
    let mut valid_handlers: Vec<Handler> = vec![];
    let mut errors: Vec<String> = vec![];

    handler_ids.iter().for_each(|entry: &String| {
        let handler_result = handler_id_to_handler(entry.to_owned());

        match (handler_result) {
            Ok(new_handler) => {
                valid_handlers.push(new_handler);
            }
            Err(new_error) => errors.push(new_error),
        }
    });

    if !errors.is_empty() {
        return Err(actions::PlayerActionHandlingError::ActionExecutorConstructionError(errors));
    }

    Ok(actions::ActionsExecutor {
        handlers: valid_handlers,
    })
}

fn handler_id_to_handler(id: String) -> Result<Handler, String> {
    match id.as_str() {
        "send_ship/v_1" => Ok(Box::new(handlers::send_ship::v_1::Handler {})),
        _ => Err(id),
    }
}
