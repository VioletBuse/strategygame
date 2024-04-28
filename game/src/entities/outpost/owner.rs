use enum_as_inner::EnumAsInner;
// use anyhow::{Result, bail};

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, EnumAsInner)]
pub enum OutpostOwner {
    OwnedOutpost(i64),
    UnownedOutpost,
}

impl From<i64> for OutpostOwner {
    fn from(value: i64) -> Self {
        Self::OwnedOutpost(value)
    }
}

impl From<Option<i64>> for OutpostOwner {
    fn from(value: Option<i64>) -> Self {
        match value {
            Some(v) => Self::OwnedOutpost(v),
            None => Self::UnownedOutpost,
        }
    }
}

impl OutpostOwner {
    pub fn new_owned(owner_id: i64) -> OutpostOwner {
        OutpostOwner::OwnedOutpost(owner_id)
    }

    pub fn new_unowned() -> OutpostOwner {
        OutpostOwner::UnownedOutpost
    }
    pub fn get_owner_id(&self) -> Option<i64> {
        match self {
            OutpostOwner::OwnedOutpost(owner_id) => Some(owner_id.clone()),
            OutpostOwner::UnownedOutpost => None,
        }
    }

    pub fn set_owner(self, owner_id: i64) -> OutpostOwner {
        OutpostOwner::OwnedOutpost(owner_id)
    }
    pub fn set_unowned(self) -> OutpostOwner {
        OutpostOwner::UnownedOutpost
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use pretty_assertions::assert_eq;

    #[test]
    fn get_owner_id() {
        assert_eq!(OutpostOwner::OwnedOutpost(1234).get_owner_id(), Some(1234));

        assert_eq!(OutpostOwner::UnownedOutpost.get_owner_id(), None);
    }

    #[test]
    fn switch_ownership() {
        let initial = OutpostOwner::UnownedOutpost;

        assert_eq!(initial.get_owner_id(), None);

        let switched_to_owned = initial.set_owner(1);

        assert_eq!(switched_to_owned.get_owner_id(), Some(1));

        let switched_to_new_owner = switched_to_owned.set_owner(2);

        assert_eq!(switched_to_new_owner.get_owner_id(), Some(2));

        let switched_to_unowned = switched_to_new_owner.set_unowned();

        assert_eq!(switched_to_unowned.get_owner_id(), None);
    }
}
