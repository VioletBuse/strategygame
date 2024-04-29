use typed_builder::TypedBuilder;

#[derive(Clone, Debug, TypedBuilder)]
pub struct Player {
    pub id: i64,
}
