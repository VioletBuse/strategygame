use enum_as_inner::EnumAsInner;

#[derive(Clone, Debug, EnumAsInner)]
pub enum OutpostOwner {
    Unowned,
    Owned(String)
}

pub enum OutpostOwnerTransitions {
    SetUnowned,
    SetOwned(String)
}

impl OutpostOwner {
    fn new_unowned() -> Self {
        Self::Unowned
    }
    fn new_owned(owner_id: String) -> Self {
        Self::Owned(owner_id)
    }
}
