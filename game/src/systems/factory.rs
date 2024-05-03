use crate::systems;
use crate::systems::handlers;

type Handler = Box<dyn systems::SystemHandler>;

pub fn system_handler_factory(
    handler_ids: Vec<String>,
) -> Result<systems::SystemExecutor, systems::SystemHandlingError> {
    let mut valid_handlers: Vec<Handler> = vec![];
    let mut errors: Vec<String> = vec![];

    handler_ids.iter().for_each(
        |entry: &String| match handler_id_to_handler(entry.to_owned()) {
            Ok(new_handler) => {
                valid_handlers.push(new_handler);
            }
            Err(new_error) => {
                errors.push(new_error);
            }
        },
    );

    if !errors.is_empty() {
        return Err(systems::SystemHandlingError::SystemExecutorConstructionError(errors));
    }

    Ok(systems::SystemExecutor {
        handlers: valid_handlers,
    })
}

fn handler_id_to_handler(id: String) -> Result<Handler, String> {
    match id.as_str() {
        "princess_promotion/v_1" => Ok(Box::new(handlers::princess_promotion::v_1::Handler {})),
        "queen_death/v_1" => Ok(Box::new(handlers::queen_death::v_1::Handler {})),
        "dead_specialist_cleanup/v_1" => Ok(Box::new(handlers::dead_specialist_cleanup::v_1::Handler {})),
        _ => Err(id),
    }
}
